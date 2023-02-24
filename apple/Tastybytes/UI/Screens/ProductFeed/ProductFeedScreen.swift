import SwiftUI

struct ProductFeedScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router

  init(_ client: Client, feed: ProductFeedType) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, feed: feed))
  }

  var body: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProductItemView(product: product, extras: [.checkInCheck, .rating])
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
      }
    }
    .listStyle(.plain)
    .navigationTitle(viewModel.feed.label)
    .task {
      await viewModel.load()
    }
  }
}
