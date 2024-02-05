import Foundation
import Models

extension Product {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, description, is_verified, is_discontinued"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.products, [saved], withTableName)
        case let .joinedBrandSubcategories(withTableName):
            return queryWithTableName(
                .products,
                [saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)),
                 Subcategory.getQuery(.joinedCategory(true)), ProductBarcode.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.productLogos))],
                withTableName
            )
        case let .joinedBrandSubcategoriesCreator(withTableName):
            return queryWithTableName(
                .products,
                [
                    saved,
                    "created_at",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ],
                withTableName
            )
        case let .joinedBrandSubcategoriesRatings(withTableName):
            return queryWithTableName(
                .products,
                [
                    saved,
                    "current_user_check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ],
                withTableName
            )
        case let .joinedBrandSubcategoriesProfileRatings(withTableName):
            return queryWithTableName(
                .products,
                [
                    saved,
                    "check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategories(_ withTableName: Bool)
        case joinedBrandSubcategoriesCreator(_ withTableName: Bool)
        case joinedBrandSubcategoriesRatings(_ withTableName: Bool)
        case joinedBrandSubcategoriesProfileRatings(_ withTableName: Bool)
    }
}

extension ProductVariant {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id"

        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(.productVariants, [saved, Company.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension ProductDuplicateSuggestion {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "product_id, duplicate_of_product_id"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.productDuplicateSuggestions, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
