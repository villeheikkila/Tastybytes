import SwiftUI

struct ProductScreenView: View {
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
                                                   onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn) })
                               },
                               header: {
                                   VStack {
                                       ProductCardView(product: product)
                                           .contextMenu {
                                               if currentProfile.hasPermission(.canDeleteProducts) {
                                                   Button(action: {
                                                       viewModel.showDeleteConfirmation()
                                                   }) {
                                                       Label("Delete", systemImage: "trash.fill")
                                                           .foregroundColor(.red)
                                                   }
                                               }
                                               Button(action: {
                                                   viewModel.setActiveSheet(.editSuggestion)
                                               }) {
                                                   Label("Edit Suggestion", systemImage: "square.and.pencil")
                                                       .foregroundColor(.red)
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
                viewModel.setActiveSheet(.checkIn)
            }) {
                Text("Check-in")
                    .bold()
            })
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .checkIn:
                CheckInSheetView(product: product, onCreation: {
                    viewModel.appendNewCheckIn(newCheckIn: $0)
                })
            case .editSuggestion:
                ProductSheetView(initialProduct: product)
            }
        }
        .confirmationDialog("delete_company",
                            isPresented: $viewModel.showDeleteProductConfirmationDialog
        ) {
            Button("Delete Product", role: .destructive, action: { viewModel.deleteProduct(product)
            })
        }
    }
}

extension ProductScreenView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case checkIn
        case editSuggestion
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var isLoading = false
        @Published var activeSheet: Sheet?
        @Published var productSummary: ProductSummary?
        @Published var showDeleteProductConfirmationDialog = false
        @Published var showEditSuggestionSheet = false

        let pageSize = 10
        var page = 0

        func refresh(productId: Int) {
            page = 0
            checkIns = []
            fetchMoreCheckIns(productId: productId)
        }

        func setActiveSheet(_ sheet: Sheet) {
            activeSheet = sheet
        }

        func showDeleteConfirmation() {
            showDeleteProductConfirmationDialog.toggle()
        }

        func loadProductSummary(_ product: ProductJoined) {
            Task {
                switch await repository.product.getSummaryById(id: product.id) {
                case let .success(summary):
                    await MainActor.run {
                        self.productSummary = summary
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func deleteCheckIn(_ checkIn: CheckIn) {
            Task {
                switch await repository.checkIn.delete(id: checkIn.id) {
                case .success():
                    self.checkIns.remove(object: checkIn)
                case let .failure(error):
                    print(error)
                }
            }
        }

        func deleteProduct(_ product: ProductJoined) {
            Task {
                switch await repository.product.delete(id: product.id) {
                case .success():
                    print("TODO HANDLE THIS!!")
                case let .failure(error):
                    print(error)
                }
            }
        }

        func onCheckInUpdate(_ checkIn: CheckIn) {
            if let index = checkIns.firstIndex(of: checkIn) {
                checkIns[index] = checkIn
            }
        }

        func fetchMoreCheckIns(productId: Int) {
            let (from, to) = getPagination(page: page, size: pageSize)

            Task {
                await MainActor.run {
                    self.isLoading = true
                }

                switch await repository.checkIn.getByProductId(id: productId, from: from, to: to) {
                case let .success(checkIns):
                    await MainActor.run {
                        self.checkIns.append(contentsOf: checkIns)
                        self.page += 1
                        self.isLoading = false
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func appendNewCheckIn(newCheckIn: CheckIn) {
            checkIns.insert(newCheckIn, at: 0)
        }
    }
}
