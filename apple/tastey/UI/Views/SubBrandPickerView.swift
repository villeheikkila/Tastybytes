import SwiftUI

struct SubBrandPickerView: View {
    let subBrands: [SubBrand]
    @State var searchText: String = ""
    @State var brandsWithSubBrands = [BrandJoinedWithSubBrands]()

    let onSelect: (_ company: SubBrand) -> Void

    var body: some View {

        NavigationStack {
            List {
                ForEach(subBrands.filter({$0.name != nil }), id: \.self) { subBrand in
                    Button(action: {self.onSelect(subBrand)}) {
                        if let name = subBrand.name {
                            Text(name)
                        }
                    }
                }
            }
            .navigationTitle("Sub-brands")

            
        }
    }
}
