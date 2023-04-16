import SwiftUI

struct ProductFilterSheet: View {
  enum Sections {
    case category, checkIns, sortBy
  }

  private let logger = getLogger(category: "SeachFilterSheet")
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var appDataManager: AppDataManager
  @State private var categoryFilter: Category.JoinedSubcategories?
  @State private var subcategoryFilter: Subcategory?
  @State private var sortBy: Product.Filter.SortBy?
  @State private var onlyNonCheckedIn = false

  let client: Client
  let sections: [Sections]
  let onApply: (_ filter: Product.Filter?) -> Void

  init(
    _ client: Client,
    initialFilter: Product.Filter?,
    sections: [Sections],
    onApply: @escaping (_ filter: Product.Filter?) -> Void
  ) {
    self.client = client
    self.sections = sections
    self.onApply = onApply

    subcategoryFilter = initialFilter?.subcategory
    categoryFilter = initialFilter?.category
    onlyNonCheckedIn = initialFilter?.onlyNonCheckedIn ?? false
    sortBy = initialFilter?.sortBy
  }

  var body: some View {
    Form {
      if sections.contains(.category) {
        Section {
          Picker(selection: $categoryFilter) {
            Text("Select All").tag(Category.JoinedSubcategories?(nil))
            ForEach(appDataManager.categories) { category in
              Text(category.name).tag(Optional(category))
            }
          } label: {
            Text("Category")
          }
          Picker(selection: $subcategoryFilter) {
            Text("Select All").tag(Subcategory?(nil))
            if let categoryFilter {
              ForEach(categoryFilter.subcategories) { subcategory in
                Text(subcategory.name).tag(Optional(subcategory))
              }
            }
          } label: {
            Text("Subcategory")
          }.disabled(categoryFilter == nil)
        } header: {
          Text("Category")
        }
      }

      if sections.contains(.checkIns) {
        Section {
          Toggle("Only things I have not had", isOn: $onlyNonCheckedIn)
        } header: {
          Text("Check-ins")
        }
      }
      if sections.contains(.sortBy) {
        Section {
          Picker(selection: $sortBy) {
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
      Button("Reset", action: { resetFilter() }).bold()
    }
    .scrollDisabled(true)
    .navigationTitle("Filter")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      Button("Cancel", role: .cancel, action: { dismiss() }).bold()
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button("Apply", action: {
        onApply(getFilter())
        dismiss()
      }).bold()
    }
  }

  func getFilter() -> Product.Filter? {
    guard !(categoryFilter == nil && subcategoryFilter == nil && onlyNonCheckedIn == false && sortBy == nil) else { return nil }
    return Product.Filter(
      category: categoryFilter,
      subcategory: subcategoryFilter,
      onlyNonCheckedIn: onlyNonCheckedIn,
      sortBy: sortBy
    )
  }

  func resetFilter() {
    withAnimation {
      categoryFilter = nil
      subcategoryFilter = nil
      onlyNonCheckedIn = false
      categoryFilter = nil
      sortBy = nil
    }
  }
}
