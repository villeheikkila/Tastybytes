import Models
import Repositories
import SwiftUI

struct SubBrandListScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    let subBrands: [SubBrand.JoinedBrand]

    var body: some View {
        List(subBrands) { subBrand in
            SubBrandEntityView(brand: subBrand.brand, subBrand: subBrand)
                .onTapGesture {
                    router.fetchAndNavigateTo(repository, .brand(id: subBrand.brand.id))
                }
        }
        .listStyle(.plain)
        .navigationTitle("subBrand.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
