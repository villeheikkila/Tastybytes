import Foundation
import Models

extension Product.Barcode: Queryable {
    private static let saved = "id, barcode, type"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.productBarcodes, [saved], withTableName)
        case let .joined(withTableName):
            buildQuery(
                .productBarcodes,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joinedCreator(withTableName):
            buildQuery(
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
