import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct SubcategoryAdminSheet: View {
    private var logger = Logger(category: "SubcategoryAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var subcategoryName = ""
    @State private var category: Models.Category.JoinedSubcategoriesServingStyles?
    @State private var subcategory: Subcategory.Detailed?

    let id: Subcategory.Id
    let onSubmit: (_ subcategoryName: String) async -> Void

    init(subcategory: SubcategoryProtocol, onSubmit: @escaping (_ subcategoryName: String) async -> Void) {
        id = subcategory.id
        _subcategoryName = State(wrappedValue: subcategory.name)
        self.onSubmit = onSubmit
    }

    var body: some View {
        Form {
            if let subcategory {
                content(subcategory: subcategory)
            }
        }
        .scrollContentBackground(.hidden)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await load()
            }
        }
        .animation(.default, value: subcategory)
        .navigationTitle("subcategory.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await load()
        }
    }

    @ViewBuilder func content(subcategory: Subcategory.Detailed) -> some View {
        Section("subcategory.admin.subcategory") {
            VStack {
                Text(subcategory.name)
            }
        }
        .customListRowBackground()

        ModificationInfoView(modificationInfo: subcategory)

        Section("admin.section.details") {
            LabeledTextFieldView(title: "subcategory.admin.name", text: $subcategoryName)
            LabeledContent("subcategory.admin.category") {
                RouterLink(category?.name ?? subcategory.category.name, open: .sheet(.categoryPicker(category: $category)))
            }
        }
        .customListRowBackground()

        Section("labels.info") {
            LabeledIdView(id: subcategory.id.rawValue.formatted())
            VerificationAdminToggleView(isVerified: subcategory.isVerified) { isVerified in
                await appEnvironmentModel.verifySubcategory(subcategory, isVerified: isVerified) {
                    withAnimation {
                        self.subcategory = subcategory.copyWith(isVerified: isVerified)
                    }
                }
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

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        if let subcategory {
            ToolbarItem(placement: .primaryAction) { [subcategoryName] in
                AsyncButton("labels.edit", action: {
                    await appEnvironmentModel.editSubcategory(.init(id: subcategory.id, name: subcategory.name))
                    await onSubmit(subcategoryName)
                })
                .disabled((subcategoryName.isEmpty || subcategory.name == subcategoryName) && subcategory.category.id == category?.id)
            }
        }
    }

    private func load() async {
        do {
            subcategory = try await repository.subcategory.getDetailed(id: id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed subcategory info. Error: \(error) (\(#file):\(#line))")
        }
    }
}
