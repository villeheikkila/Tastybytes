import Foundation
import Models

extension Report: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, message"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.reports, [saved], withTableName)
        case let .joined(withTableName):
            return buildQuery(.reports, ["id, message, created_at", Profile.getQuery(.minimal(true)), Product.getQuery(.joinedBrandSubcategories(true)), Company.getQuery(.saved(true)), SubBrand.getQuery(.joinedBrand(true)), CheckInComment.getQuery(.joinedProfile(true)), CheckIn.getQuery(.joined(true))], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
    }
}
