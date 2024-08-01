import Foundation
public import Tagged

public extension SubBrand {
    struct JoinedProduct: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let products: [Product.JoinedCategory]

        public init(id: SubBrand.Id, name: String? = nil, includesBrandName: Bool, isVerified: Bool, products: [Product.JoinedCategory]) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.isVerified = isVerified
            self.products = products
        }

        public init(subBrand: SubBrand.Detailed) {
            id = subBrand.id
            name = subBrand.name
            includesBrandName = subBrand.includesBrandName
            isVerified = subBrand.isVerified
            products = subBrand.products
        }

        public init(subBrand: SubBrand.JoinedProductJoined) {
            id = subBrand.id
            name = subBrand.name
            includesBrandName = subBrand.includesBrandName
            isVerified = subBrand.isVerified
            products = subBrand.products.map { .init(product: $0) }
        }

        public var subBrand: SubBrand.Saved {
            .init(id: id, name: name, includesBrandName: includesBrandName, isVerified: isVerified)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case includesBrandName = "includes_brand_name"
            case products
        }

        public static func < (lhs: JoinedProduct, rhs: JoinedProduct) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }

        public func copyWith(name: String? = nil, includesBrandName: Bool? = nil, isVerified: Bool? = nil, products: [Product.JoinedCategory]? = nil) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                includesBrandName: includesBrandName ?? self.includesBrandName,
                isVerified: isVerified ?? self.isVerified,
                products: products ?? self.products
            )
        }
    }
}

public extension SubBrand {
    struct JoinedProductJoined: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let products: [Product.Joined]

        public init(
            subBrand: SubBrand.JoinedBrand,
            products: [Product.Joined]
        ) {
            id = subBrand.id
            name = subBrand.name
            includesBrandName = subBrand.includesBrandName
            isVerified = subBrand.isVerified
            self.products = products
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case includesBrandName = "includes_brand_name"
            case products
        }

        public static func < (lhs: JoinedProductJoined, rhs: JoinedProductJoined) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }
    }
}
