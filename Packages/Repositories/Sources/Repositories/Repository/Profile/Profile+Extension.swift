import Foundation
import Models

extension Profile: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let minimal = "id, is_private, preferred_name, joined_at"
        let saved =
            "id, first_name, last_name, username, name_display, preferred_name, is_private, is_onboarded, joined_at"

        switch queryType {
        case let .minimal(withTableName):
            return buildQuery(.profiles, [minimal, ImageEntity.getQuery(.saved(.profileAvatars))], withTableName)
        case let .extended(withTableName):
            return buildQuery(
                .profiles,
                [saved, ProfileSettings.getQuery(.saved(true)), Role.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.profileAvatars))],
                withTableName
            )
        case let .contribtions(withTableName):
            return buildQuery(
                .profiles,
                [saved, buildQuery(name: "products", foreignKey: "products!products_created_by_fkey", [Product.getQuery(.joinedBrandSubcategories(false))]), buildQuery(name: "companies", foreignKey: "companies!companies_created_by_fkey", [Company.getQuery(.saved(false))]), buildQuery(name: "brands", foreignKey: "brands!brands_created_by_fkey", [Brand.getQuery(.saved(false))]), buildQuery(name: "sub_brands", foreignKey: "sub_brands!sub_brands_created_by_fkey", [SubBrand.getQuery(.saved(false))]), buildQuery(name: "barcodes", foreignKey: "product_barcodes!product_barcodes_created_by_fkey", [ProductBarcode.getQuery(.joined(false))])],
                withTableName
            )
        }
    }

    enum QueryType {
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
        case contribtions(_ withTableName: Bool)
    }
}

extension Role: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(.roles, [saved, Permission.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Permission: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.permissions, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}

extension ProfileWishlist: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "created_by"

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(
                .profileWishlistItems,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension ProfileSettings: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved =
            """
            id, send_reaction_notifications, send_tagged_check_in_notifications,\
            send_friend_request_notifications, send_comment_notifications
            """

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.profileSettings, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}

extension CategoryStatistics {
    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "id, name, icon, count"
        }
    }
}

extension Contributions {
    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "products, companies, brands, sub_brands, barcodes"
        }
    }
}

extension SubcategoryStatistics {
    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "id, name, count"
        }
    }
}
