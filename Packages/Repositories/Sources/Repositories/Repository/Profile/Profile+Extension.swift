import Foundation
import Models

extension Profile {
    static func getQuery(_ queryType: QueryType) -> String {
        let minimal = "id, is_private, preferred_name, joined_at"
        let saved =
            "id, first_name, last_name, username, name_display, preferred_name, is_private, is_onboarded, joined_at"

        switch queryType {
        case let .minimal(withTableName):
            return queryWithTableName(.profiles, [minimal, ImageEntity.getQuery(.saved(.profileAvatars))], withTableName)
        case let .extended(withTableName):
            return queryWithTableName(
                .profiles,
                [saved, ProfileSettings.getQuery(.saved(true)), Role.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.profileAvatars))],
                withTableName
            )
        }
    }

    enum QueryType {
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
    }
}

extension Role {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(.roles, [saved, Permission.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Permission {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.permissions, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}

extension ProfileWishlist {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "created_by"

        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(
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

extension ProfileSettings {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved =
            """
            id, send_reaction_notifications, send_tagged_check_in_notifications,\
            send_friend_request_notifications, send_comment_notifications
            """

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.profileSettings, [saved], withTableName)
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
