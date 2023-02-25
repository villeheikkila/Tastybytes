import CachedAsyncImage
import SwiftUI

struct MergeSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
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
          }, label: {
            ProductItemView(product: product, extras: [.rating, .checkInCheck])
          }).buttonStyle(.plain)
        }
      }
    }
    .navigationTitle("Merge to...")
    .navigationBarItems(trailing: Button(role: .cancel, action: {
      dismiss()
    }, label: {
      Text("Cancel").bold()
    }))
    .confirmationDialog("Product Merge Confirmation",
                        isPresented: $viewModel.isPresentingProductMergeConfirmation,
                        presenting: viewModel.mergeToProduct) { presenting in
      Button("Merge \(presenting.name) to \(presenting.getDisplayName(.fullName))", role: .destructive) {
        viewModel.mergeProducts(productToMerge: productToMerge, onSuccess: {
          hapticManager.trigger(of: .notification(.success))
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
