import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct SubcategorySheet: View {
    private let logger = Logger(category: "SubcategorySheet")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var subcategories: [Subcategory]
    @State private var showAddSubcategory = false
    @State private var newSubcategoryName = ""
    @State private var searchTerm = ""
    let category: Models.Category.JoinedSubcategoriesServingStyles

    private let maxSubcategories = 4

    var shownSubcategories: [Subcategory] {
        category.subcategories.sorted().filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
    }

    var body: some View {
        List {
            Section("Subcategories of \(category.name)") {
                ForEach(shownSubcategories) { subcategory in
                    Button(action: { toggleSubcategory(subcategory: subcategory) }, label: {
                        HStack {
                            Text(subcategory.name)
                            Spacer()
                            Label("Selected subcategory", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                                .opacity(subcategories.contains(subcategory) ? 1 : 0)
                        }
                    })
                }
            }
        }
        .searchable(text: $searchTerm)
        .navigationTitle("Subcategories")
        .toolbar {
            toolbarContent
        }
        .alert("Add new subcategory", isPresented: $showAddSubcategory, actions: {
            TextField("TextField", text: $newSubcategoryName)
            Button("Cancel", role: .cancel, action: {})
            ProgressButton("Create", action: {
                await appDataEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
            })
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Done", role: .cancel, action: { dismiss() }).bold()
        }
        if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Add subcategory", systemImage: "plus", action: { showAddSubcategory.toggle() })
                    .labelStyle(.iconOnly)
                    .bold()
            }
        }
    }

    private func toggleSubcategory(subcategory: Subcategory) {
        if subcategories.contains(subcategory) {
            withAnimation {
                subcategories.remove(object: subcategory)
            }
        } else if subcategories.count < maxSubcategories {
            withAnimation {
                subcategories.append(subcategory)
            }
        } else {
            feedbackEnvironmentModel.toggle(.warning("You can only add \(maxSubcategories) subcategories"))
        }
    }
}
