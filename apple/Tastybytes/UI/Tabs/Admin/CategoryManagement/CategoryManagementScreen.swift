import SwiftUI

struct CategoryManagementScreen: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.categories) { category in
        Section {
          Section {
            ForEach(category.subcategories) { subcategory in
              HStack {
                Text(subcategory.label)
              }
            }
          } header: {
            Text("Subcategories")
          }
        } header: {
          Text(category.name.label)
        }
      }
    }.task {
      await viewModel.loadCategories()
    }
  }
}

extension CategoryManagementScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CategoryManagementScreen")

    let client: Client
    @Published var categories = [Category.JoinedSubcategoriesServingStyles]()

    init(_ client: Client) {
      self.client = client
    }

    func loadCategories() async {
      switch await client.category.getAllWithSubcategoriesServingStyles() {
      case let .success(categories):
        self.categories = categories
      case let .failure(error):
        logger.error("failed to load categories: \(error.localizedDescription)")
      }
    }
  }
}
