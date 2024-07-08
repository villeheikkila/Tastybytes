import Models
import Repositories
import SwiftUI

struct SubBrandListScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    let subBrands: [SubBrand.JoinedBrand]

    var body: some View {
        List(subBrands) { subBrand in
            RouterLink(open: .screen(.brandById(id: subBrand.brand.id, initialScrollPosition: subBrand))) {
                SubBrandEntityView(brand: subBrand.brand, subBrand: subBrand)
            }
        }
        .listStyle(.plain)
        .verificationBadgeVisibility(.visible)
        .navigationTitle("subBrand.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
