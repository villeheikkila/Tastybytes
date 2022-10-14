import SwiftUI

struct ProductPageView: View {
    let product: Product
    @StateObject private var model = ProductPageViewViewModel()
    @State private var showingSheet = false

    var body: some View {
        ScrollView {
            VStack {
                ProductCardView(product: product)

                Button(action: {
                    showingSheet.toggle()
                }) {
                    Text("Check-in!").font(.system(size: 14, weight: .bold, design: .default))
                }.buttonStyle(GrowingButton())
                    .sheet(isPresented: $showingSheet) {
                        AddCheckInView(product: product, onCreation: {
                            model.appendNewCheckIn(newCheckIn: $0)
                        })
                    }
            }
            
            InfiniteScroll(data: $model.checkIns, isLoading: $model.isLoading, loadMore: { model.fetchMoreCheckIns(productId: product.id) }, refresh: { model.refreshCheckIns() },
                           content: {
                CheckInCardView(checkIn: $0)
            })
        }
    }
}



struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ProductPageView {
    @MainActor class ProductPageViewViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()

        @Published var isLoading = false
        let pageSize = 5
        var page = 0

        func refreshCheckIns() {
            // TODO: Implement fetching of new items
        }

        func fetchMoreCheckIns(productId: Int) {
            let (from, to) = getPagination(page: page, size: pageSize)

            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }

                let checkIns = try await SupabaseCheckInRepository().loadByProductId(id: productId, from: from, to: to)

                DispatchQueue.main.async {
                    self.checkIns.append(contentsOf: checkIns)
                    self.page += 1
                    self.isLoading = false
                }
            }
        }
        
        
        func appendNewCheckIn(newCheckIn: CheckIn) {
            DispatchQueue.main.async {
                self.checkIns.insert(newCheckIn, at: 0)
            }
            
        }
    }
}
