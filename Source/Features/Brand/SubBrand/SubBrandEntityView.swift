import SwiftUI
import Models

struct SubBrandEntityView: View {
    let subBrand: SubBrand.JoinedBrand
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(subBrand.brand.name)
            Text(subBrand.name ?? "-")
        }
    }
}
