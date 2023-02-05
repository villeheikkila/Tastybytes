import CachedAsyncImage
import SwiftUI

struct MergeSheetView: View {
  @StateObject private var viewModel: ViewModel
  @State private var showDeleteCompanyConfirmationDialog = false
  @State private var showDeleteBrandConfirmationDialog = false
  @Environment(\.dismiss) private var dismiss

  let productToMerge: Product.JoinedCategory

  init(
    _ client: Client,
    productToMerge: Product.JoinedCategory
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.productToMerge = productToMerge
  }

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
    .confirmationDialog("Product Merge Confirmation",
                        isPresented: $viewModel.isPresentingProductMergeConfirmation,
                        presenting: viewModel.mergeToProduct) { presenting in
      Button("Merge \(presenting.name) to \(presenting.getDisplayName(.fullName))", role: .destructive) {
        viewModel.mergeProducts(productToMerge: productToMerge, onSuccess: {
          dismiss()
        })
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
    private let logger = getLogger(category: "MergeSheetView")
    let client: Client
    @Published var mergeToProduct: Product.Joined?
    @Published var isPresentingProductMergeConfirmation = false
    @Published var productSearchTerm = ""
    @Published var productSearchResults: [Product.Joined] = []

    init(_ client: Client) {
      self.client = client
    }

    func mergeProducts(productToMerge: Product.JoinedCategory, onSuccess: @escaping () -> Void) {
      if let mergeToProduct {
        Task {
          switch await client.product.mergeProducts(productId: productToMerge.id, toProductId: mergeToProduct.id) {
          case .success:
            self.mergeToProduct = nil
            onSuccess()
          case let .failure(error):
            logger
              .error(
                "merging product \(productToMerge.id) to \(mergeToProduct.id) failed: \(error.localizedDescription)"
              )
          }
        }
      }
    }

    func searchProducts(productToMerge: Product.JoinedCategory) {
      Task {
        switch await client.product.search(searchTerm: productSearchTerm, categoryName: nil) {
        case let .success(searchResults):
          self.productSearchResults = searchResults.filter { $0.id != productToMerge.id }
        case let .failure(error):
          logger
            .error(
              "searching products for merge with ter, \(self.productSearchTerm) failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
