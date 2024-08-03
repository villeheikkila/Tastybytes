import Foundation

public enum EditSuggestion: Hashable, Identifiable, Sendable, Decodable {
    case product(Product.EditSuggestion)
    case company(Company.EditSuggestion)
    case brand(Brand.EditSuggestion)
    case subBrand(SubBrand.EditSuggestion)

    public var id: Int {
        hashValue
    }

    public var createdAt: Date {
        switch self {
        case let .brand(editSuggestion):
            editSuggestion.createdAt
        case let .product(editSuggestion):
            editSuggestion.createdAt
        case let .company(editSuggestion):
            editSuggestion.createdAt
        case let .subBrand(editSuggestion):
            editSuggestion.createdAt
        }
    }

    public var createdBy: Profile.Saved {
        switch self {
        case let .brand(editSuggestion):
            editSuggestion.createdBy
        case let .product(editSuggestion):
            editSuggestion.createdBy
        case let .company(editSuggestion):
            editSuggestion.createdBy
        case let .subBrand(editSuggestion):
            editSuggestion.createdBy
        }
    }

    public var resolvedAt: Date? {
        switch self {
        case let .brand(editSuggestion):
            editSuggestion.resolvedAt
        case let .product(editSuggestion):
            editSuggestion.resolvedAt
        case let .company(editSuggestion):
            editSuggestion.resolvedAt
        case let .subBrand(editSuggestion):
            editSuggestion.resolvedAt
        }
    }
}
