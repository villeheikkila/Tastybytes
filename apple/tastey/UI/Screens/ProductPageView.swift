import SwiftUI

struct ProductPageView: View {
    let product: ProductJoined
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var currentProfile: CurrentProfile
    
    var body: some View {
        ZStack(alignment: .bottom) {
            InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, loadMore: { viewModel.fetchMoreCheckIns(productId: product.id) }, refresh: { viewModel.refresh(productId: product.id) },
                               content: {
                CheckInCardView(checkIn: $0,
                                loadedFrom: .product,
                                onDelete: { checkIn in viewModel.deleteCheckIn(checkIn) },
                                onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn) })},
        header: {
            VStack {
                ProductCardView(product: product)
                    .contextMenu {
                        if currentProfile.hasPermission(.canDeleteProducts) {
                            Button(action: {
                                viewModel.deleteProduct(product)
                            }) {
                                Label("Delete", systemImage: "trash.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                
                VStack(spacing: 10) {
                    if let checkIns = viewModel.productSummary?.totalCheckIns {
                        HStack {
                            Text("Check-ins:")
                            Spacer()
                            Text(String(checkIns))
                        }
                    }
                    if let averageRating = viewModel.productSummary?.averageRating {
                        HStack {
                            Text("Average:")
                            Spacer()
                            RatingView(rating: averageRating)
                        }
                    }
                    if let currentUserAverageRating = viewModel.productSummary?.currentUserAverageRating {
                        HStack {
                            Text("Your rating:")
                            Spacer()
                            RatingView(rating: currentUserAverageRating)
                        }
                    }
                }.padding(.all, 10)
            }
        }
            )
        }
        .task {
            viewModel.loadProductSummary(product)
        }
        .navigationBarItems(
            trailing: Button(action: {
                viewModel.showingSheet.toggle()
            }) {
                Text("Check-in")
                    .bold()
            })
        .sheet(isPresented: $viewModel.showingSheet) {
            CheckInSheetView(product: product, onCreation: {
                viewModel.appendNewCheckIn(newCheckIn: $0)
            })
        }
    }
}

extension ProductPageView {
    @MainActor class ViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var isLoading = false
        @Published var showingSheet = false
        @Published var productSummary: ProductSummary?
        
        let pageSize = 5
        var page = 0
        
        func refresh(productId: Int) {
            page = 0
            checkIns = []
            fetchMoreCheckIns(productId: productId)
        }
        
        func loadProductSummary(_ product: ProductJoined) {
            Task {
                let summary = try await repository.product.getSummaryById(id: product.id)
                DispatchQueue.main.async {
                    self.productSummary = summary
                }
            }
        }
        
        func deleteCheckIn(_ checkIn: CheckIn) {
            Task {
                do {
                    try await repository.checkIn.delete(id: checkIn.id)
                    self.checkIns.remove(object: checkIn)
                } catch {
                    print("error: \(error)")
                }
            }
        }
        
        func deleteProduct(_ product: ProductJoined) {
            Task {
                do {
                    try await repository.product.delete(id: product.id)
                } catch {
                    print("error \(error)")
                }
            }
        }
        
        func onCheckInUpdate(_ checkIn: CheckIn) {
            if let index = checkIns.firstIndex(of: checkIn) {
                DispatchQueue.main.async {
                    self.checkIns[index] = checkIn
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
        
        func updateCheckIn(updatedCheckIn: CheckIn) {
            DispatchQueue.main.async {
                self.checkIns.insert(updatedCheckIn, at: 0)
            }
        }
    }
}
