import SwiftUI

struct ProductVerificationScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProductItemView(product: product)
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
          .swipeActions {
            Button(action: { viewModel.verifyProduct(product) }, label: {
              Label("Verify", systemImage: "checkmark")
            }).tint(.green)
          }
      }
    }
    .listStyle(.plain)
    .navigationBarTitle("Unverified Products")
    .refreshable {
      await viewModel.loadProducts()
    }
    .task {
      await viewModel.loadProducts()
    }
  }
}
