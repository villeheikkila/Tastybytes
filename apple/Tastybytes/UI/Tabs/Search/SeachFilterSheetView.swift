import SwiftUI

struct SeachFilterSheetView: View {
  @StateObject private var viewModel: ViewModel

  init(
    _ client: Client
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    Form {
      Picker(selection: $viewModel.categoryFilter) {
        Text("Select All").tag(Category.Name?(nil))
        ForEach(viewModel.categoryOptions, id: \.self) { category in
          Text(category.label).tag(Optional(category))
        }
      } label: {
        Text("Category")
      }
//      Picker(selection: $viewModel.categoryFilter) {
//        if let categoryFilter = viewModel.categoryFilter {
//          ForEach(categoryFilter.subcategories) { subcategory in
//            Text(subcategory.name.capitalized)
//          }
//        }
//      } label: {
//        Text("Subcategory")
//      }.disabled(viewModel.categoryFilter == nil)
    }.task {
      await viewModel.loadCategories()
    }
  }
}

enum CategoryOptions: Hashable, Identifiable {
  var id: String {
    switch self {
    case .selectAll:
      return "select_all"
    case let .category(category):
      return category.rawValue
    }
  }

  case category(Category.Name)
  case selectAll

  var label: String {
    switch self {
    case .selectAll:
      return "Select All"
    case let .category(category):
      return category.label
    }
  }
}

extension SeachFilterSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "SeachFilterSheetView")
    let client: Client
    @Published var categories: [Category.JoinedSubcategories] = []
    @Published var categoryOptions: [Category.Name] = []
    @Published var categoryFilter: Category.Name?
    @Published var subcategoryFilter: Subcategory?

    init(_ client: Client) {
      self.client = client
    }

    func loadCategories() async {
      switch await client.category.getAllWithSubcategories() {
      case let .success(categories):
        self.categories = categories
        categoryOptions = categories.map(\.name)
      // categoryOptions = [CategoryOptions.selectAll] + categoryNames
      case let .failure(error):
        logger.error("failed to load categories: \(error.localizedDescription)")
      }
    }
  }
}
