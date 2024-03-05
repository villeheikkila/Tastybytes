import Foundation
import Models

extension Report: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(.reports, ["id, message, created_at", Profile.getQuery(.minimal(true)), Product.getQuery(.joinedBrandSubcategories(true)), Company.getQuery(.saved(true)), SubBrand.getQuery(.joinedBrand(true)), CheckInComment.getQuery(.joinedCheckIn(true)), CheckIn.getQuery(.joined(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
