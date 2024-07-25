import Foundation
import Models

extension Company: Queryable {
    private static let saved = "id, name, is_verified"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos))], withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            buildQuery(
                .companies,
                [
                    saved,
                    Company.getQuery(.saved(true)),
                    Brand.getQuery(.joined(true)),
                    ImageEntity.getQuery(.saved(.companyLogos)),
                ],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .companies,
                [
                    saved,
                    ImageEntity.getQuery(.saved(.companyLogos)),
                    Company.EditSuggestion.getQuery(.joined(true)),
                    Company.getQuery(.saved(true)),
                    Report.getQuery(.joined(true)),
                    Product.Variant.getQuery(.joinedProduct(true)),
                    modificationInfoFragment,
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
