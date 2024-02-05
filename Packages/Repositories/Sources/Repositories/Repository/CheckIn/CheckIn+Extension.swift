import Foundation
import Models

extension CheckIn {
    static func getQuery(_ queryType: QueryType) -> String {
        let fromFriendsView = "view_check_ins_from_friends"
        let image = "id, blur_hash, created_by"
        let saved = "id, rating, review, check_in_at, blur_hash"
        let checkInTaggedProfilesJoined = "check_in_tagged_profiles (\(Profile.getQuery(.minimal(true))))"
        let productVariantJoined = "product_variants (id, \(Company.getQuery(.saved(true))))"
        let checkInFlavorsJoined = "check_in_flavors (\(Flavor.getQuery(.saved(true))))"

        switch queryType {
        case .fromFriendsView:
            return fromFriendsView
        case let .segmentedView(segment):
            switch segment {
            case .everyone:
                return Database.Table.checkIns.rawValue
            case .friends:
                return "view__check_ins_from_friends"
            case .you:
                return "view__check_ins_from_current_user"
            }
        case let .joined(withTableName):
            return queryWithTableName(
                .categories,
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
                    ImageEntity.getQuery(.saved(.checkInImages)),
                ],
                withTableName
            )
        case let .image(withTableName):
            return queryWithTableName(
                .categories,
                [image, ImageEntity.getQuery(.saved(.checkInImages))],
                withTableName
            )
        }
    }

    enum QueryType {
        case segmentedView(CheckInSegment)
        case fromFriendsView
        case joined(_ withTableName: Bool)
        case image(_ withTableName: Bool)
    }
}

extension Models.Notification.CheckInTaggedProfiles {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id"

        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(
                .checkInTaggedProfiles,
                [saved, CheckIn.getQuery(.joined(true))],
                withTableName
            )
        }
    }

    enum QueryType {
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
