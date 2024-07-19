import Foundation
import Models

extension Report: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, message, created_at"

        return switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .reports,
                [
                    saved,
                    buildQuery(name: "created_by", foreignKey: "created_by", [Profile.getQuery(.minimal(false))]),
                    buildQuery(name: "profiles", foreignKey: "profile_id", [Profile.getQuery(.minimal(false))]),
                    Product.getQuery(.joinedBrandSubcategories(true)), Company.getQuery(.saved(true)), SubBrand.getQuery(.joinedBrand(true)),
                    CheckInComment.getQuery(.joinedCheckIn(true)),
                    CheckIn.getQuery(.joined(true)),
                    Location.getQuery(.joined(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
