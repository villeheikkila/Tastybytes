import SwiftUI

struct ProductFeedScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router

  init(_ client: Client, feed: ProductFeedType) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, feed: feed))
  }

  var body: some View {
    List {
      ForEach(viewModel.filteredProducts) { product in
        ProductItemView(product: product, extras: [.checkInCheck, .rating])
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
          .onAppear {
            if product == viewModel.products.last, viewModel.isLoading != true {
              Task {
                await viewModel.fetchProductFeedItems()
              }
            }
          }
      }
      if viewModel.isLoading {
        ProgressView()
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .refreshable {
      await viewModel.refresh()
    }
    .navigationTitle(viewModel.title)
    .toolbar {
      toolbarContent
    }
    .task {
      await viewModel.loadIntialData()
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarTitleMenu {
      Button(action: { viewModel.categoryFilter = nil }, label: {
        Text(viewModel.feed.label)
      })
      ForEach(viewModel.categories) { category in
        Button(action: { viewModel.categoryFilter = category }, label: {
          Text(category.name.label)
        })
      }
    }
  }
}
