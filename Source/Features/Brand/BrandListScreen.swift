import Models
import Repositories
import SwiftUI

struct BrandListScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    let brands: [Brand.Saved]

    var body: some View {
        List(brands) { brand in
            RouterLink(open: .screen(.brand(brand.id))) {
                BrandView(brand: brand)
            }
        }
        .listStyle(.plain)
        .verificationBadgeVisibility(.visible)
        .navigationTitle("brand.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
