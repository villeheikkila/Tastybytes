import CachedAsyncImage
import SwiftUI

struct MergeSheetView: View {
  let productToMerge: Product.JoinedCategory
  @StateObject private var viewModel = ViewModel()
  @State private var showDeleteCompanyConfirmationDialog = false
  @State private var showDeleteBrandConfirmationDialog = false
  @Environment(\.dismiss) var dismiss

  var body: some View {
    List {
      if let productSearchResults = viewModel.productSearchResults {
        ForEach(productSearchResults, id: \.self) { product in
          Button(action: {
            viewModel.mergeToProduct = product
            viewModel.isPresentingProductMergeConfirmation.toggle()
          }) {
            ProductListItemView(product: product)
          }.buttonStyle(.plain)
        }
      }
    }
    .navigationTitle("Merge to...")
    .confirmationDialog("Are you sure?",
                        isPresented: $viewModel.isPresentingProductMergeConfirmation) {
      Button("Merge. This can't be undone.", role: .destructive) {
        viewModel.mergeProducts(productToMerge: productToMerge, onSuccess: {
          dismiss()
        })
      }
    } message: {
      if let mergeToProduct = viewModel.mergeToProduct {
        Text("Merge \(productToMerge.name) to \(mergeToProduct.getDisplayName(.fullName))")
      }
    }
    .searchable(text: $viewModel.productSearchTerm)
    .onSubmit(of: .search) {
      viewModel.searchProducts(productToMerge: productToMerge)
    }
  }
}

extension MergeSheetView {
  @MainActor class ViewModel: ObservableObject {
    @Published var mergeToProduct: Product.Joined?
    @Published var isPresentingProductMergeConfirmation = false
    @Published var productSearchTerm = ""
    @Published var productSearchResults: [Product.Joined] = []

    func mergeProducts(productToMerge: Product.JoinedCategory, onSuccess: @escaping () -> Void) {
      if let mergeToProduct {
        Task {
          switch await repository.product.mergeProducts(productId: productToMerge.id, toProductId: mergeToProduct.id) {
          case .success():
            self.mergeToProduct = nil
            onSuccess()
          case let .failure(error):
            print(error)
          }
        }
      }
    }

    func searchProducts(productToMerge: Product.JoinedCategory) {
      Task {
        switch await repository.product.search(searchTerm: productSearchTerm, categoryName: nil) {
        case let .success(searchResults):
          await MainActor.run {
            self.productSearchResults = searchResults.filter { $0.id != productToMerge.id }
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
