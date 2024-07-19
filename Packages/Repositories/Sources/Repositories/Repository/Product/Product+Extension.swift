import Foundation
import Models

extension Product: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, description, is_verified, is_discontinued"

        return switch queryType {
        case let .saved(withTableName):
            buildQuery(.products, [saved], withTableName)
        case let .joinedBrandSubcategories(withTableName):
            buildQuery(
                .products,
                [saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)),
                 Subcategory.getQuery(.joinedCategory(true)), Product.Barcode.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.productLogos))],
                withTableName
            )
        case let .joinedBrandSubcategoriesCreator(withTableName):
            buildQuery(
                .products,
                [
                    saved,
                    buildQuery(name: "profiles", foreignKey: "created_by", [Profile.getQuery(.minimal(false))]),
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    Product.Barcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ],
                withTableName
            )
        case let .joinedBrandSubcategoriesRatings(withTableName):
            buildQuery(
                .products,
                [
                    saved,
                    "current_user_check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    Product.Barcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ],
                withTableName
            )
        case let .joinedBrandSubcategoriesProfileRatings(withTableName):
            buildQuery(
                .products,
                [
                    saved,
                    "check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    Product.Barcode.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                ],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .products,
                [
                    saved,
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    Product.Barcode.getQuery(.joinedCreator(true)),
                    Product.EditSuggestion.getQuery(.joined(true)),
                    Product.Variant.getQuery(.joined(true)),
                    buildQuery(
                        name: "product_duplicate_suggestions",
                        foreignKey: "product_duplicate_suggestions!product_duplicate_suggestion_product_id_fkey",
                        [Product.DuplicateSuggestion.getQuery(.joined(false))]
                    ),
                    Report.getQuery(.joined(true)),
                    ImageEntity.getQuery(.saved(.productLogos)),
                    modificationInfoFragment,
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
        case detailed(_ withTableName: Bool)
    }
}

extension Product.Variant: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id"

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(.productVariants, [saved, Company.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Product.EditSuggestion: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, created_at, name, description, is_discontinued"

        return switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .productEditSuggestions,
                [
                    saved,
                    Product.getQuery(.joinedBrandSubcategories(true)),
                    Profile.getQuery(.minimal(true)),
                    Category.getQuery(.saved(true)),
                    SubBrand.getQuery(.joinedBrand(true)),
                    Product.EditSuggestion.SubcategoryEditSuggestion.getQuery(.joined(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Product.EditSuggestion.SubcategoryEditSuggestion: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, delete"

        return switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .productEditSuggestionSubcategories,
                [
                    saved,
                    Subcategory.getQuery(.joinedCategory(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Product.DuplicateSuggestion: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, created_at"

        return switch queryType {
        case let .saved(withTableName):
            buildQuery(.productDuplicateSuggestions, [saved], withTableName)
        case let .joined(withTableName):
            buildQuery(
                .productDuplicateSuggestions,
                [
                    saved,
                    Profile.getQuery(.minimal(true)),
                    buildQuery(name: "product", foreignKey: "product_id", [Product.getQuery(.joinedBrandSubcategoriesCreator(false))]),
                    buildQuery(name: "duplicate", foreignKey: "duplicate_of_product_id", [Product.getQuery(.joinedBrandSubcategoriesCreator(false))]),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
    }
}
