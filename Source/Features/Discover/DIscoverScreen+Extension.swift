import Models
import SwiftUI

extension DiscoverScreen {
    enum SearchScope: String, CaseIterable, Identifiable {
        var id: Self { self }
        case products, companies, users, locations

        var label: String {
            switch self {
            case .products:
                "Products"
            case .companies:
                "Companies"
            case .users:
                "Users"
            case .locations:
                "Locations"
            }
        }

        var prompt: String {
            switch self {
            case .products:
                "Search products, brands..."
            case .users:
                "Search users"
            case .companies:
                "Search companies"
            case .locations:
                "Search locations"
            }
        }
    }

    enum SearchKey: Hashable, Identifiable {
        case barcode(Barcode)
        case text(searchTerm: String, searchScope: SearchScope)

        var id: String {
            switch self {
            case let .barcode(barcode):
                "barcode::id\(barcode.id)"
            case let .text(searchTerm, searchScope):
                "text::scope:\(searchScope.rawValue)::search_term:\(searchTerm)"
            }
        }
    }
}
