import SwiftUI

struct DuplicateProductSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, mode: Mode, product: Product.Joined) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, mode: mode, product: product))
  }

  var body: some View {
    List {
      if viewModel.products.isEmpty, viewModel.mode == .reportDuplicate {
        Text(
          """
          Search for duplicate of \(viewModel.product.getDisplayName(.fullName)). \
          Your request will be reviewed and products will be combined if appropriate.
          """
        ).listRowSeparator(.hidden)
      }
      ForEach(viewModel.products.filter { $0.id != viewModel.product.id }) { product in
        Button(action: { viewModel.mergeToProduct = product }, label: {
          ProductItemView(product: product)
        })
      }
    }
    .listStyle(.plain)
    .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a duplicate product")
    .disableAutocorrection(true)
    .onSubmit(of: .search) {
      viewModel.searchProducts()
    }
    .navigationTitle(viewModel.mode == .mergeDuplicate ? "Merge duplicates" : "Mark a duplicate")
    .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Close").bold()
    }))
    .onReceive(
      viewModel.$searchTerm.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
    ) { _ in
      viewModel.searchProducts()
    }
    .confirmationDialog("Product Merge Confirmation",
                        isPresented: $viewModel.showMergeToProductConfirmation,
                        presenting: viewModel.mergeToProduct)
    { presenting in
      Button(
        """
        \(viewModel.mode == .mergeDuplicate ? "Merge" : "Mark") \(presenting.name) \(viewModel
          .mode == .mergeDuplicate ? "to" : "as duplicate of") \(presenting.getDisplayName(.fullName))
        """,
        role: .destructive
      ) {
        viewModel.primaryAction(onSuccess: {
          hapticManager.trigger(of: .notification(.success))
          dismiss()
        })
      }
    }
  }
}
