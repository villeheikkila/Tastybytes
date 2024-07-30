import Foundation
import Models

extension CheckIn: Queryable {
    private static let saved = "id, rating, review, check_in_at, is_nostalgic"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .checkIns,
                [
                    saved,
                    buildQuery(name: "profiles", foreignKey: "created_by", [Profile.getQuery(.minimal(false))]),
                    Product.getQuery(.joinedBrandSubcategories(true)),
                    CheckIn.Reaction.getQuery(.joinedProfile(true)),
                    buildQuery(.checkInTaggedProfiles, [Profile.getQuery(.minimal(true))], true),
                    Flavor.getQuery(.saved(true)),
                    buildQuery(.productVariants, ["id", Company.getQuery(.saved(true))], true),
                    ServingStyle.getQuery(.saved(true)),
                    buildQuery(name: "locations", foreignKey: "location_id", [Location.getQuery(.joined(false))]),
                    buildQuery(name: "purchase_location", foreignKey: "purchase_location_id", [Location.getQuery(.joined(false))]),
                    ImageEntity.getQuery(.saved(.checkInImages)),
                ],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .checkIns,
                [
                    saved,
                    Product.getQuery(.joinedBrandSubcategories(true)),
                    CheckIn.Reaction.getQuery(.joinedProfile(true)),
                    buildQuery(.checkInTaggedProfiles, [Profile.getQuery(.minimal(true))], true),
                    Flavor.getQuery(.saved(true)),
                    buildQuery(.productVariants, ["id", Company.getQuery(.saved(true))], true),
                    ServingStyle.getQuery(.saved(true)),
                    buildQuery(name: "locations", foreignKey: "location_id", [Location.getQuery(.joined(false))]),
                    buildQuery(name: "purchase_location", foreignKey: "purchase_location_id", [Location.getQuery(.joined(false))]),
                    ImageEntity.getQuery(.saved(.checkInImages)),
                    Report.getQuery(.joined(true)),
                    modificationInfoFragment,
                ],
                withTableName
            )
        case let .image(withTableName):
            buildQuery(
                .checkInImages,
                [ImageEntity.getQuery(.saved(nil)), "check_in_id"],
                withTableName
            )
        case let .imageDetailed(withTableName):
            buildQuery(
                .checkInImages,
                [
                    ImageEntity.getQuery(.saved(nil)),
                    CheckIn.getQuery(.joined(true)),
                    Report.getQuery(.joined(true)),
                    Profile.getQuery(.minimal(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
        case image(_ withTableName: Bool)
        case imageDetailed(_ withTableName: Bool)
    }
}

extension CheckIn.Segment {
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
