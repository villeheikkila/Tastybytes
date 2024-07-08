import Models
import Repositories
import SwiftUI

struct BrandListScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    let brands: [Brand]

    var body: some View {
        List(brands) { brand in
            BrandEntityView(brand: brand)
                .onTapGesture {
                    router.fetchAndNavigateTo(repository, .brand(id: brand.id))
                }
        }
        .listStyle(.plain)
        .navigationTitle("brand.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
