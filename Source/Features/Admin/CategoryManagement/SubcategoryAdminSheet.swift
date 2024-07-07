import Components
import EnvironmentModels
import Models
import SwiftUI

struct SubcategoryAdminSheet: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var subcategoryName = ""
    @State private var category: Models.Category.JoinedSubcategoriesServingStyles?
    let subcategory: Subcategory.JoinedCategory
    let onSubmit: (_ subcategoryName: String) async -> Void

    init(subcategory: Subcategory.JoinedCategory, onSubmit: @escaping (_ subcategoryName: String) async -> Void) {
        _subcategoryName = State(wrappedValue: subcategory.name)
        self.subcategory = subcategory
        self.onSubmit = onSubmit
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    Text(subcategory.name)
                }
            }
            .customListRowBackground()

            Section {
                LabeledTextField(title: "subcategory.admin.name", text: $subcategoryName)
                LabeledContent("subcategory.admin.category") {
                    RouterLink(category?.name ?? subcategory.category.name, open: .sheet(.categoryPicker(category: $category)))
                }
            }
            .customListRowBackground()

            Section {
                LabeledIdView(id: subcategory.id.formatted())
                VerificationAdminToggleView(isVerified: subcategory.isVerified) { isVerified in
                    await appEnvironmentModel.verifySubcategory(.init(subcategory: subcategory), isVerified: isVerified)
                }
            }
            .customListRowBackground()

            Section {
                ConfirmedDeleteButtonView(presenting: subcategory, action: { presenting in
                    await appEnvironmentModel.deleteSubcategory(presenting)
                }, description: "subcategory.delete.confirmation.description", label: "subcategory.delete.confirmation.label \(subcategory.name)", isDisabled: subcategory.isVerified)
            }
            .customListRowBackground()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("subcategory.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.saveChanges", action: {
                await appEnvironmentModel.editSubcategory(.init(id: subcategory.id, name: subcategory.name))
                await onSubmit(subcategoryName)
            })
            .disabled((subcategoryName.isEmpty || subcategory.name == subcategoryName) && subcategory.category.id == category?.id)
        }
    }
}
