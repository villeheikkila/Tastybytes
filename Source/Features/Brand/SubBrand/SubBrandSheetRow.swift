import Models
import SwiftUI

@MainActor
struct SubBrandSheetRow: View {
    let subBrand: SubBrandProtocol
    let onClick: (_ brand: SubBrandProtocol) -> Void

    var body: some View {
        Button(action: {
            onClick(subBrand)
        }, label: {
            HStack(alignment: .center) {
                if let name = subBrand.name {
                    Text(name)
                }
                Spacer()
            }
        })
        .listRowBackground(Color.clear)
    }
}
