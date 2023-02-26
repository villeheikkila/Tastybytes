import SwiftUI

struct ContributionsScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      Button(action: { viewModel.activeSheet = .products }, label: {
        HStack {
          Text("Products")
          Spacer()
          Text(String(viewModel.products.count))
        }
      })
    }
    .navigationTitle("Your Contributions")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .products:
          DismissableSheet(title: "Products") {
            contributedProductsSheet
          }
        }
      }
    }
    .task {
      viewModel.loadContributions(userId: profileManager.getId())
    }
  }

  private var contributedProductsSheet: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProductItemView(product: product)
      }
    }
  }
}

