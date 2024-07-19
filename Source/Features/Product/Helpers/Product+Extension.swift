import Models
import SwiftUI

public struct ProductFormatter<Output> {
    let format: (ProductProtocol) -> Output
}

public extension ProductProtocol {
    func formatted<Output>(_ formatter: ProductFormatter<Output>) -> Output {
        formatter.format(self)
    }
}

public extension ProductFormatter where Output == String {
    static var fullName: Self {
        .init { value in
            [
                value.subBrand.includesBrandName ? nil : value.subBrand.brand.name,
                value.subBrand.name,
                value.name, value.isDiscontinued ? String(localized: "product.discontinued.label") : nil,
            ]
            .joinOptionalSpace()
        }
    }

    static var full: Self {
        .init { value in
            [
                value.subBrand.brand.brandOwner.name,
                value.subBrand.includesBrandName ? nil : value.subBrand.brand.name,
                value.subBrand.name,
                value.name,
                value.isDiscontinued ? String(localized: "product.discontinued.label") : nil,
            ]
            .joinOptionalSpace()
        }
    }

    static var brandOwner: Self {
        .init { value in
            value.subBrand.brand.brandOwner.name
        }
    }
}

public extension Product.Filter.SortBy {
    var label: LocalizedStringKey {
        switch self {
        case .highestRated:
            "product.filter.sortBy.highestRated.label"
        case .lowestRated:
            "product.filter.sortBy.lowestRated.label"
        }
    }
}

public extension Product.FeedType {
    var label: LocalizedStringKey {
        switch self {
        case .topRated:
            "product.feed.topRated.label"
        case .trending:
            "product.feed.trending.label"
        case .latest:
            "product.feed.latest.label"
        }
    }
}
