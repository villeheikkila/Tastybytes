import Foundation
import Models

extension Product.Barcode: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, barcode, type"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.productBarcodes, [saved], withTableName)
        case let .joined(withTableName):
            return buildQuery(
                .productBarcodes,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joinedCreator(withTableName):
            return buildQuery(
                .productBarcodes,
                [saved, "created_at", Profile.getQuery(.minimal(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedCreator(_ withTableName: Bool)
    }
}
