import Foundation
import Models

extension ProductBarcode {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, barcode, type"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.productBarcodes, [saved], withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                .productBarcodes,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joinedCreator(withTableName):
            return queryWithTableName(
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
