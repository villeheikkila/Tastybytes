import SwiftUI

struct ProductPageView: View {
    let product: ProductResponse
    @StateObject private var model = ProductPageViewViewModel()

        
    var body: some View {
        ScrollView {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text(product.sub_brands.brands.name)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    if product.sub_brands.name != "" {
                        Text(product.sub_brands.name)
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    Text(product.name)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    Text(product.sub_brands.brands.companies.name)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.gray)
                    
                }
                .padding(.all, 10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(.darkGray))
            .cornerRadius(5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            
            
            ForEach(model.checkIns, id: \.id) { checkIn in
                CheckInCardView(checkIn: checkIn)
            }
        }.task {
            model.getInitialData(productId: product.id)
        }
    }
}

extension ProductPageView {
    @MainActor class ProductPageViewViewModel: ObservableObject {
        @Published var checkIns = [CheckInResponse]()

        func getInitialData(productId: Int) {
            let checkInQuery = API.supabase.database
                .from("check_ins")
                .select(columns: "id, rating, review, created_at, profiles (id, username, avatar_url), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, avatar_url))")
                .eq(column: "product_id", value: productId)
                .order(column: "created_at")
                .limit(count: 5)

            Task {
                let checkIns = try await checkInQuery.execute().decoded(to: [CheckInResponse].self)
                DispatchQueue.main.async {
                    self.checkIns = checkIns
                }
            }
        }
    }
}
