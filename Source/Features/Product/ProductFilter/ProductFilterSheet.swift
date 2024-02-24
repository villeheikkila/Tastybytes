import Components
import EnvironmentModels
import Models
import OSLog
import SwiftUI

@MainActor
struct ProductFilterSheet: View {
    enum Sections {
        case category, checkIns, sortBy
    }

    private let logger = Logger(category: "SeachFilterSheet")
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var categoryFilter: Models.Category.JoinedSubcategoriesServingStyles?
    @State private var subcategoryFilter: Subcategory?
    @State private var sortBy: Product.Filter.SortBy?
    @State private var onlyNonCheckedIn = false

    let sections: [Sections]
    let onApply: (_ filter: Product.Filter?) -> Void

    init(
        initialFilter: Product.Filter?,
        sections: [Sections],
        onApply: @escaping (_ filter: Product.Filter?) -> Void
    ) {
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
                Section("category.title") {
                    Picker(selection: $categoryFilter) {
                        Text("labels.selectAll").tag(Models.Category.JoinedSubcategoriesServingStyles?(nil))
                        ForEach(appEnvironmentModel.categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    } label: {
                        Text("category.picker.label")
                    }
                    .pickerStyle(.navigationLink)
                    Picker(selection: $subcategoryFilter) {
                        Text("labels.selectAll").tag(Subcategory?(nil))
                        if let categoryFilter {
                            ForEach(categoryFilter.subcategories) { subcategory in
                                Text(subcategory.name).tag(Optional(subcategory))
                            }
                        }
                    } label: {
                        Text("subcategory.picker.label")
                    }
                    .pickerStyle(.navigationLink)
                    .disabled(categoryFilter == nil)
                }
            }

            if sections.contains(.checkIns) {
                Section("checkIn.title") {
                    Toggle("checkIn.filter.onlyNotHad", isOn: $onlyNonCheckedIn)
                }
            }
            if sections.contains(.sortBy) {
                Section("labels.sortBy") {
                    Picker(selection: $sortBy) {
                        Text("labels.none").tag(Product.Filter.SortBy?(nil))
                        ForEach(Product.Filter.SortBy.allCases) { sortBy in
                            Text(sortBy.label).tag(Optional(sortBy))
                        }
                    } label: {
                        Text("checkIn.rating.label")
                    }
                }
            }
            Button("product.filter.reset", action: { resetFilter() }).bold()
        }
        .navigationTitle("product.filter.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .confirmationAction) {
            Button("labels.apply", action: {
                onApply(getFilter())
                dismiss()
            }).bold()
        }
    }

    func getFilter() -> Product.Filter? {
        guard !(categoryFilter == nil && subcategoryFilter == nil && onlyNonCheckedIn == false && sortBy == nil)
        else { return nil }
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
