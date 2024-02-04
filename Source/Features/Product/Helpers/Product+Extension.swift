
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

extension Product.Filter.SortBy {
        public var label: LocalizedStringKey {
            switch self {
            case .highestRated:
                "product.filter.sortBy.highestRated.label"
            case .lowestRated:
                "product.filter.sortBy.lowestRated.label"
            }
        }
}

extension Product.FeedType{
    public var label: String {
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
