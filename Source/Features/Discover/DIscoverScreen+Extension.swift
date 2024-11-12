import Models
import SwiftUI

extension DiscoverTab {
    enum SearchScope: String, CaseIterable, Identifiable {
        var id: Self { self }
        case products, companies, users, locations

        var label: LocalizedStringKey {
            switch self {
            case .products:
                "discover.products.label"
            case .companies:
                "discover.companies.label"
            case .users:
                "discover.users.label"
            case .locations:
                "discover.locations.label"
            }
        }

        var prompt: LocalizedStringKey {
            switch self {
            case .products:
                "discover.products.prompt"
            case .users:
                "discover.users.prompt"
            case .companies:
                "discover.companies.prompt"
            case .locations:
                "discover.locations.prompt"
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
