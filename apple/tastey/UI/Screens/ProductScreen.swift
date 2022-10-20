import SwiftUI

struct ProductPageView: View {
    let product: Product
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, loadMore: { viewModel.fetchMoreCheckIns(productId: product.id) }, refresh: { viewModel.refresh(productId: product.id) },
                               content: {
                                   CheckInCardView(checkIn: $0, onDelete: {
                                       deletedCheckIn in viewModel.deleteCheckIn(id: deletedCheckIn.id)
                                   })
                               },
                               header: {
                                   ProductCardView(product: product)
                               }
            )
        }

        Button(action: {
            viewModel.showingSheet.toggle()
        }) {
            Text("Check-in!").font(.system(size: 14, weight: .bold, design: .default))
        }
        .buttonStyle(GrowingButton())
        .sheet(isPresented: $viewModel.showingSheet) {
            AddCheckInView(product: product, onCreation: {
                viewModel.appendNewCheckIn(newCheckIn: $0)
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
    @MainActor class ViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var isLoading = false
        @Published var showingSheet = false

        let pageSize = 5
        var page = 0

        func refresh(productId: Int) {
            page = 0
            checkIns = []
            fetchMoreCheckIns(productId: productId)
        }

        func deleteCheckIn(id: Int) {
            Task {
                do {
                    try await repository.checkIn.delete(id: id)
                    self.checkIns.removeAll(where: { $0.id == id })
                } catch {
                    print("error: \(error)")
                }
            }
        }

        func fetchMoreCheckIns(productId: Int) {
            let (from, to) = getPagination(page: page, size: pageSize)

            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }

                let checkIns = try await repository.checkIn.getByProductId(id: productId, from: from, to: to)

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
