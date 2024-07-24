import Foundation
public import Tagged

public extension SubBrand {
    struct JoinedBrand: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let brand: Brand.JoinedCompany

        public init(id: SubBrand.Id, name: String?, includesBrandName: Bool, isVerified: Bool, brand: Brand.JoinedCompany) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.brand = brand
            self.isVerified = isVerified
        }

        public init(brand: Brand.JoinedSubBrandsProductsCompany, subBrand: SubBrand.JoinedProduct) {
            id = subBrand.id
            name = subBrand.name
            isVerified = subBrand.isVerified
            includesBrandName = subBrand.includesBrandName
            self.brand = .init(brand: brand)
        }

        public init(subBrand: SubBrand.Detailed) {
            id = subBrand.id
            name = subBrand.name
            isVerified = subBrand.isVerified
            includesBrandName = subBrand.includesBrandName
            brand = subBrand.brand
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            includesBrandName = false
            brand = .init()
            isVerified = false
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case brand = "brands"
            case includesBrandName = "includes_brand_name"
            case isVerified = "is_verified"
        }

        public static func < (lhs: JoinedBrand, rhs: JoinedBrand) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }

        public func copyWith(
            name: String?? = nil,
            includesBrandName: Bool? = nil,
            isVerified: Bool? = nil,
            brand: Brand.JoinedCompany? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                includesBrandName: includesBrandName ?? self.includesBrandName,
                isVerified: isVerified ?? self.isVerified,
                brand: brand ?? self.brand
            )
        }
    }
}
