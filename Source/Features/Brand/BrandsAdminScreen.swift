import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct BrandsAdminScreen: View {
    @Environment(Repository.self) private var repository
    @State private var brands = [Brand.JoinedCompany]()
    @State private var state: ScreenState = .loading
    @State private var searchTerm = ""

    private var filtered: [Brand.JoinedCompany] {
        brands.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var body: some View {
        List(filtered) { brand in
            RouterLink(open: .sheet(.brandAdmin(id: brand.id, onUpdate: { brand in
                brands = brands.replacingWithId(brand.id, with: .init(brand: brand))
            }, onDelete: { id in
                brands = brands.removingWithId(id)
            }))) {
                BrandEntityView(brand: brand)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .refreshable {
            await initialize()
        }
        .verificationBadgeVisibility(.visible)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .navigationTitle("brandsAdmin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .initialTask {
            await initialize()
        }
    }

    private func initialize() async {
        do {
            brands = try await repository.brand.getAll()
            state = .populated
        } catch {
            state = .error([error])
        }
    }
}
