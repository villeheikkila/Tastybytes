import Foundation
import Models

extension Profile: Queryable {
    private static let minimal = "id, is_private, preferred_name, joined_at"
    private static let saved =
        "id, first_name, last_name, username, name_display, preferred_name, is_private, is_onboarded, joined_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .minimal(withTableName):
            buildQuery(.profiles, [minimal, ImageEntity.getQuery(.saved(.profileAvatars))], withTableName)
        case let .extended(withTableName):
            buildQuery(
                .profiles,
                [saved, Profile.Settings.getQuery(.saved(true)), Role.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.profileAvatars))],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .profiles,
                [saved, Role.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.profileAvatars))],
                withTableName
            )
        }
    }

    enum QueryType {
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}

extension ProfileWishlist: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .profileWishlistItems,
                [Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Profile.Settings: Queryable {
    private static let saved = "id, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_comment_notifications"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.profileSettings, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}

extension CategoryStatistics {
    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "id, name, icon, count"
        }
    }

    enum QueryPart {
        case value
    }
}

extension SubcategoryStatistics {
    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "id, name, count"
        }
    }

    enum QueryPart {
        case value
    }
}

extension Profile.Contributions: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .profiles,
                [
                    buildQuery(name: "products", foreignKey: "products!products_created_by_fkey", [Product.getQuery(.joinedBrandSubcategories(false))]),
                    buildQuery(name: "companies", foreignKey: "companies!companies_created_by_fkey", [Company.getQuery(.saved(false))]),
                    buildQuery(name: "brands", foreignKey: "brands!brands_created_by_fkey", [Brand.getQuery(.saved(false))]),
                    buildQuery(name: "sub_brands", foreignKey: "sub_brands!sub_brands_created_by_fkey", [SubBrand.getQuery(.joinedBrand(false))]),
                    buildQuery(name: "barcodes", foreignKey: "product_barcodes!product_barcodes_created_by_fkey", [Product.Barcode.getQuery(.joined(false))]),
                    buildQuery(name: "reports", foreignKey: "reports!reports_created_by_fkey", [Report.getQuery(.joined(false))]),
                    Product.EditSuggestion.getQuery(.joined(true)),
                    Company.EditSuggestion.getQuery(.joined(true)),
                    Brand.EditSuggestion.getQuery(.joined(true)),
                    SubBrand.EditSuggestion.getQuery(.joined(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
