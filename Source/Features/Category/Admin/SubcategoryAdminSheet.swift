import Components

import Models
import OSLog
import Repositories
import SwiftUI

struct SubcategoryAdminSheet: View {
    typealias OnEditCallback = (_ subcategoryName: String) async -> Void

    private var logger = Logger(category: "SubcategoryAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var subcategoryName = ""
    @State private var subcategory = Subcategory.Detailed()

    let id: Subcategory.Id
    let onEdit: OnEditCallback

    init(
        id: Subcategory.Id,
        onEdit: @escaping OnEditCallback
    ) {
        self.id = id
        self.onEdit = onEdit
    }

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .animation(.default, value: subcategory)
        .navigationTitle("subcategory.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await initialize()
        }
    }

    @ViewBuilder var content: some View {
        Section("subcategory.admin.subcategory") {
            SubcategoryView(subcategory: subcategory)
        }
        .customListRowBackground()

        ModificationInfoView(modificationInfo: subcategory)

        Section("admin.section.details") {
            LabeledTextFieldView(title: "subcategory.admin.name", text: $subcategoryName)
        }
        .customListRowBackground()

        Section("labels.info") {
            LabeledIdView(id: subcategory.id.rawValue.formatted())
            VerificationAdminToggleView(isVerified: subcategory.isVerified) { isVerified in
                await appModel.verifySubcategory(subcategory, isVerified: isVerified) {
                    subcategory = subcategory.copyWith(isVerified: isVerified)
                }
            }
        }
        .customListRowBackground()

        Section {
            ConfirmedDeleteButtonView(presenting: subcategory, action: { presenting in
                await appModel.deleteSubcategory(presenting)
            }, description: "subcategory.delete.confirmation.description", label: "subcategory.delete.confirmation.label \(subcategory.name)", isDisabled: subcategory.isVerified)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) { [subcategoryName] in
            AsyncButton("labels.edit", action: {
                await appModel.editSubcategory(.init(id: subcategory.id, name: subcategory.name))
                await onEdit(subcategoryName)
            })
            .disabled(subcategoryName.isEmpty || subcategory.name == subcategoryName)
        }
    }

    private func initialize() async {
        do {
            subcategory = try await repository.subcategory.getDetailed(id: id)
            subcategoryName = subcategory.name
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load detailed subcategory info. Error: \(error) (\(#file):\(#line))")
        }
    }
}
