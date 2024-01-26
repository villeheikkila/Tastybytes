import Foundation
import Models

extension Profile {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profiles.rawValue
        let minimal = "id, is_private, preferred_name, joined_at"
        let saved =
            "id, first_name, last_name, username, name_display, preferred_name, is_private, is_onboarded, joined_at"

        switch queryType {
        case .tableName:
            return tableName
        case let .minimal(withTableName):
            return queryWithTableName(tableName, [minimal, ImageEntity.getQuery(.saved(.profileAvatars))].joinComma(), withTableName)
        case let .extended(withTableName):
            return queryWithTableName(
                tableName,
                [saved, ProfileSettings.getQuery(.saved(true)), Role.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.profileAvatars))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
    }
}

extension Role {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.roles.rawValue
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, Permission.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

extension Permission {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.permissions.rawValue
        let saved = "id, name"

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

extension ProfileWishlist {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profileWishlistItems.rawValue
        let saved = "created_by"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

extension ProfileSettings {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profileSettings.rawValue
        let saved =
            """
            id, send_reaction_notifications, send_tagged_check_in_notifications,\
            send_friend_request_notifications, send_comment_notifications
            """

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
