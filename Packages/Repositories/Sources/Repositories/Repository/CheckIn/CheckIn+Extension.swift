import Foundation
import Models

extension CheckIn: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let image = "id, blur_hash, created_by"
        let saved = "id, rating, review, check_in_at, is_nostalgic"

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(
                .checkIns,
                [
                    saved,
                    Profile.getQuery(.minimal(true)),
                    Product.getQuery(.joinedBrandSubcategories(true)),
                    CheckInReaction.getQuery(.joinedProfile(true)),
                    buildQuery(.checkInTaggedProfiles, [Profile.getQuery(.minimal(true))], true),
                    buildQuery(.checkInFlavors, [Flavor.getQuery(.saved(true))], true),
                    buildQuery(.productVariants, ["id", Company.getQuery(.saved(true))], true),
                    ServingStyle.getQuery(.saved(true)),
                    buildQuery(name: "locations", foreignKey: "location_id", [Location.getQuery(.joined(false))]),
                    buildQuery(name: "purchase_location", foreignKey: "purchase_location_id", [Location.getQuery(.joined(false))]),
                    ImageEntity.getQuery(.saved(.checkInImages)),
                ],
                withTableName
            )
        case let .image(withTableName):
            return buildQuery(
                .checkIns,
                [image, ImageEntity.getQuery(.saved(.checkInImages))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
        case image(_ withTableName: Bool)
    }
}

extension Models.Notification.CheckInTaggedProfiles: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id"

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(
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
