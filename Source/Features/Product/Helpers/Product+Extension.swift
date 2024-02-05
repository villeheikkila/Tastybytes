
import Models
import SwiftUI

public extension Product.Joined {
    struct Formatter<Output> {
        let format: (Product.Joined) -> Output
    }

    func formatted<Output>(_ formatter: Formatter<Output>) -> Output {
        formatter.format(self)
    }
}

public extension Product.Joined.Formatter where Output == String {
    static var fullName: Self {
        .init { value in
            [value.subBrand.brand.name, value.subBrand.name, value.name, value.isDiscontinued ? String(localized: "product.discontinued.label") : nil]
                .joinOptionalSpace()
        }
    }

    static var full: Self {
        .init { value in
            [
                value.subBrand.brand.brandOwner.name,
                value.subBrand.brand.name,
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
    var label: String {
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
