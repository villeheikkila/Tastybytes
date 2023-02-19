import SwiftUI

struct ProductFilterSheetView: View {
  @StateObject private var viewModel: ViewModel
  @Environment(\.dismiss) private var dismiss

  let sections: [Sections]
  let onApply: (_ filter: Product.Filter?) -> Void

  init(
    _ client: Client,
    initialFilter: Product.Filter?,
    sections: [Sections],
    onApply: @escaping (_ filter: Product.Filter?) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, initialFilter: initialFilter))
    self.sections = sections
    self.onApply = onApply
  }

  var body: some View {
    Form {
      if sections.contains(.category) {
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
      }

      if sections.contains(.checkIns) {
        Section {
          Toggle("Only things I have not had", isOn: $viewModel.onlyNonCheckedIn)
        } header: {
          Text("Check-ins")
        }
      }
      if sections.contains(.sortBy) {
        Section {
          Picker(selection: $viewModel.sortBy) {
            Text("None").tag(Product.Filter.SortBy?(nil))
            ForEach(Product.Filter.SortBy.allCases) { sortBy in
              Text(sortBy.label).tag(Optional(sortBy))
            }
          } label: {
            Text("Rating")
          }
        } header: {
          Text("Sort By")
        }
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
        viewModel.resetFilter()
      }) {
        Text("Reset")
          .bold()
      }
      Button(action: {
        onApply(viewModel.getFilter())
      }) {
        Label("Apply", systemImage: "line.3.horizontal.decrease.circle.fill")
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
