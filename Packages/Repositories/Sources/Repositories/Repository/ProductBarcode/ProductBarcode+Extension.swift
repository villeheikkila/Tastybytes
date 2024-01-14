import Foundation
import Models

extension ProductBarcode {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.productBarcodes.rawValue
        let saved = "id, barcode, type"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        case let .joinedCreator(withTableName):
            return queryWithTableName(
                tableName,
                [saved, "created_at", Profile.getQuery(.minimal(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedCreator(_ withTableName: Bool)
    }
}
