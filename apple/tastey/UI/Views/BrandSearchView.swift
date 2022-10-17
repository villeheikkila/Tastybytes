import SwiftUI

struct BrandSearchView: View {
    let brandOwner: Company
    @State var searchText: String = ""
    @State var brandsWithSubBrands = [BrandJoinedWithSubBrands]()

    let onSelect: (_ company: BrandJoinedWithSubBrands) -> Void

    var body: some View {

        NavigationStack {
            List {
                ForEach(brandsWithSubBrands, id: \.self) { brand in
                    Button(action: {self.onSelect(brand)}) {
                        Text(brand.name)
                    }
                }
            }
            .navigationTitle("Brands")

            
        }.task {
            loadBrands()
        }
    }
    
    func loadBrands() {
        Task {
            do {
                let brandsWithSubBrands = try await SupabaseBrandRepository().loadByBrandOwnerId(brandOwnerId: brandOwner.id)
                DispatchQueue.main.async {
                    self.brandsWithSubBrands = brandsWithSubBrands
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
