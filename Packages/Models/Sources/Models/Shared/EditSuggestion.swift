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
}
