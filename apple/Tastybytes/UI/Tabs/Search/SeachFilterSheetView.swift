import SwiftUI

struct SeachFilterSheetView: View {
  @StateObject private var viewModel: ViewModel
  @Environment(\.dismiss) private var dismiss

  let onApply: (_ filter: Product.Filter) -> Void

  init(
    _ client: Client,
    initialFilter: Product.Filter?,
    onApply: @escaping (_ filter: Product.Filter) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, initialFilter: initialFilter))
    self.onApply = onApply
  }

  var body: some View {
    Form {
      Section {
        Picker(selection: $viewModel.categoryFilter) {
          Text("Select All").tag(Category.JoinedSubcategories?(nil))
          ForEach(viewModel.categories, id: \.self) { category in
            Text(category.name.label).tag(Optional(category))
          }
        } label: {
          Text("Category")
        }
        Picker(selection: $viewModel.subcategoryFilter) {
          Text("Select All").tag(Subcategory?(nil))
          if let categoryFilter = viewModel.categoryFilter {
            ForEach(categoryFilter.subcategories) { subcategory in
              Text(subcategory.name.capitalized).tag(Optional(subcategory))
            }
          }
        } label: {
          Text("Subcategory")
        }.disabled(viewModel.categoryFilter == nil)
      } header: {
        Text("Category")
      }

      Section {
        Toggle("Only things I have not had", isOn: $viewModel.onlyNonCheckedIn)
      } header: {
        Text("Check-ins")
      }
    }
    .navigationTitle("Filter")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }

    .task {
      await viewModel.loadCategories()
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      Button(action: {
        dismiss()
      }) {
        Text("Cancel")
          .bold()
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: {
        onApply(Product.Filter(
          category: viewModel.categoryFilter,
          subcategory: viewModel.subcategoryFilter,
          onlyNonCheckedIn: viewModel.onlyNonCheckedIn
        ))
      }) {
        Text("Apply")
          .bold()
      }
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
    @Published var categoryFilter: Category.JoinedSubcategories?
    @Published var subcategoryFilter: Subcategory?
    @Published var onlyNonCheckedIn: Bool = false
    init(_ client: Client, initialFilter: Product.Filter?) {
      self.client = client
      subcategoryFilter = initialFilter?.subcategory
      categoryFilter = initialFilter?.category
      onlyNonCheckedIn = initialFilter?.onlyNonCheckedIn ?? false
    }

    func loadCategories() async {
      switch await client.category.getAllWithSubcategories() {
      case let .success(categories):
        self.categories = categories
      // categoryOptions = [CategoryOptions.selectAll] + categoryNames
      case let .failure(error):
        logger.error("failed to load categories: \(error.localizedDescription)")
      }
    }
  }
}
