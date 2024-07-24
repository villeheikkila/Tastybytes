import Foundation
public import Tagged

public extension SubBrand {
    struct Saved: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool

        public init(id: SubBrand.Id, name: String?, includesBrandName: Bool, isVerified: Bool) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.isVerified = isVerified
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case includesBrandName = "includes_brand_name"
            case isVerified = "is_verified"
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }
    }
}
