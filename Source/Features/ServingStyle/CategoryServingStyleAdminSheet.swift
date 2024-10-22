import Components

import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct CategoryServingStyleAdminSheet: View {
    private let logger = Logger(label: "CategoryServingStyleAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(\.dismiss) private var dismiss
    @State private var servingStyles: [ServingStyle.Saved]

    let category: Models.Category.Detailed

    init(category: Models.Category.Detailed) {
        self.category = category
        _servingStyles = State(wrappedValue: category.servingStyles)
    }

    var body: some View {
        List(servingStyles) { servingStyle in
            CategoryServingStyleRow(category: category, servingStyle: servingStyle, deleteServingStyle: deleteServingStyle)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink(
                "servingStyle.create.label",
                systemImage: "plus",
                open: .sheet(.servingStyleManagement(
                    pickedServingStyles: $servingStyles,
                    onSelect: { servingStyle in
                        await addServingStyleToCategory(servingStyle)
                    }
                ))
            )
            .bold()
        }
    }

    private func addServingStyleToCategory(_ servingStyle: ServingStyle.Saved) async {
        do {
            try await repository.category.addServingStyle(categoryId: category.id, servingStyleId: servingStyle.id)
            withAnimation {
                servingStyles.append(servingStyle)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to add serving style to category'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteServingStyle(_ servingStyle: ServingStyle.Saved) async {
        do {
            try await repository.category.deleteServingStyle(categoryId: category.id, servingStyleId: servingStyle.id)
            withAnimation {
                servingStyles.remove(object: servingStyle)
            }
            feedbackModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete serving style '\(servingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CategoryServingStyleRow: View {
    @State private var showDeleteServingStyleConfirmation = false

    let category: Models.Category.Detailed
    let servingStyle: ServingStyle.Saved
    let deleteServingStyle: (_ servingStyle: ServingStyle.Saved) async -> Void

    var body: some View {
        ServingStyleView(servingStyle: servingStyle)
            .swipeActions {
                Button(
                    "labels.delete",
                    systemImage: "trash",
                    action: { showDeleteServingStyleConfirmation = true }
                )
                .tint(.red)
            }
            .confirmationDialog(
                "servingStyle.deleteWarning.title",
                isPresented: $showDeleteServingStyleConfirmation,
                titleVisibility: .visible,
                presenting: servingStyle
            ) { presenting in
                AsyncButton(
                    "servingStyle.deleteWarning.label \(presenting.name) from \(category.name)",
                    role: .destructive,
                    action: {
                        await deleteServingStyle(presenting)
                    }
                )
            }
    }
}
