import Foundation
import Models

extension Location {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, title, longitude, latitude, country_code, source"

        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(.locations, [saved, Country.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension Location.RecentLocation {
    var view: Database.Table {
        switch self {
        case .checkIn:
            .viewRecentLocationsFromCurrentUser
        case .purchase:
            .viewRecentPurchaseLocationsFromCurrentUser
        }
    }
}
