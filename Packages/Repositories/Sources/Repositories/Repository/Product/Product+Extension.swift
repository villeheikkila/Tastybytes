import Foundation
import Models

extension Product {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.products.rawValue
        let saved = "id, name, description, is_verified, is_discontinued"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedBrandSubcategories(withTableName):
            return queryWithTableName(
                tableName,
                [saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)),
                 Subcategory.getQuery(.joinedCategory(true)), ProductBarcode.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.productLogos))].joinComma(),
                withTableName
            )
        case let .joinedBrandSubcategoriesCreator(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    "created_at",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ].joinComma(),
                withTableName
            )
        case let .joinedBrandSubcategoriesRatings(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    "current_user_check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ].joinComma(),
                withTableName
            )
        case let .joinedBrandSubcategoriesProfileRatings(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    "check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategories(_ withTableName: Bool)
        case joinedBrandSubcategoriesCreator(_ withTableName: Bool)
        case joinedBrandSubcategoriesRatings(_ withTableName: Bool)
        case joinedBrandSubcategoriesProfileRatings(_ withTableName: Bool)
    }
}

extension ProductVariant {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.productVariants.rawValue
        let saved = "id"

        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, Company.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension ProductDuplicateSuggestion {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "product_duplicate_suggestions"
        let saved = "product_id, duplicate_of_product_id"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
