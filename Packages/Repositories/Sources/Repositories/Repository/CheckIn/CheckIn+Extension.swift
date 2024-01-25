import Foundation
import Models

extension CheckIn {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkIns.rawValue
        let fromFriendsView = "view_check_ins_from_friends"
        let image = "id, image_file, blur_hash, created_by"
        let saved = "id, rating, review, image_file, check_in_at, blur_hash"
        let checkInTaggedProfilesJoined = "check_in_tagged_profiles (\(Profile.getQuery(.minimal(true))))"
        let productVariantJoined = "product_variants (id, \(Company.getQuery(.saved(true))))"
        let checkInFlavorsJoined = "check_in_flavors (\(Flavor.getQuery(.saved(true))))"

        switch queryType {
        case .tableName:
            return tableName
        case .fromFriendsView:
            return fromFriendsView
        case let .segmentedView(segment):
            switch segment {
            case .everyone:
                return tableName
            case .friends:
                return "view__check_ins_from_friends"
            case .you:
                return "view__check_ins_from_current_user"
            }
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    Profile.getQuery(.minimal(true)),
                    Product.getQuery(.joinedBrandSubcategories(true)),
                    CheckInReaction.getQuery(.joinedProfile(true)),
                    checkInTaggedProfilesJoined,
                    checkInFlavorsJoined,
                    productVariantJoined,
                    ServingStyle.getQuery(.saved(true)),
                    "locations:location_id (\(Location.getQuery(.joined(false))))",
                    "purchase_location:purchase_location_id (\(Location.getQuery(.joined(false))))",
                    ImageEntity.getQuery(.saved(.checkInImages))
                ].joinComma(),
                withTableName
            )
        case let .image(withTableName):
            return queryWithTableName(
                tableName,
                image,
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case segmentedView(CheckInSegment)
        case fromFriendsView
        case joined(_ withTableName: Bool)
        case image(_ withTableName: Bool)
    }
}

extension Models.Notification.CheckInTaggedProfiles {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInTaggedProfiles.rawValue
        let saved = "id"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

extension CheckInSegment {
    var table: Database.Table {
        switch self {
        case .everyone:
            .checkIns
        case .friends:
            .viewCheckInsFromFriends
        case .you:
            .viewCheckInsFromCurrentUser
        }
    }
}
