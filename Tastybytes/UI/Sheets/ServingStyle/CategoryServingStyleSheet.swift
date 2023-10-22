import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CategoryServingStyleSheet: View {
    private let logger = Logger(category: "CategoryServingStyleSheet")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var servingStyles: [ServingStyle]
    @State private var showDeleteServingStyleConfirmation = false
    @State private var alertError: AlertError?
    @State private var toDeleteServingStyle: ServingStyle? {
        didSet {
            showDeleteServingStyleConfirmation = true
        }
    }

    let category: Models.Category.JoinedSubcategoriesServingStyles

    init(category: Models.Category.JoinedSubcategoriesServingStyles) {
        self.category = category
        _servingStyles = State(wrappedValue: category.servingStyles)
    }

    var body: some View {
        List(servingStyles) { servingStyle in
            HStack {
                Text(servingStyle.label)
            }
            .swipeActions {
                Button(
                    "Delete",
                    systemImage: "trash",
                    role: .destructive,
                    action: { toDeleteServingStyle = servingStyle }
                )
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .confirmationDialog(
            "Are you sure you want to delete the serving style? The serving style information for affected check-ins will be permanently lost",
            isPresented: $showDeleteServingStyleConfirmation,
            titleVisibility: .visible,
            presenting: toDeleteServingStyle
        ) { presenting in
            ProgressButton(
                "Remove \(presenting.name) from \(category.name)",
                role: .destructive,
                action: {
                    await deleteServingStyle(presenting)
                }
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .cancellationAction) {
            Button("Done", role: .cancel, action: { dismiss() })
        }
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink(
                "Add Serving Style",
                systemImage: "plus",
                sheet: .servingStyleManagement(
                    pickedServingStyles: $servingStyles,
                    onSelect: { servingStyle in
                        await addServingStyleToCategory(servingStyle)
                    }
                )
            )
            .bold()
        }
    }

    func addServingStyleToCategory(_ servingStyle: ServingStyle) async {
        switch await repository.category.addServingStyle(
            categoryId: category.id,
            servingStyleId: servingStyle.id
        ) {
        case .success:
            withAnimation {
                servingStyles.append(servingStyle)
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to add serving style to category'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteServingStyle(_ servingStyle: ServingStyle) async {
        switch await repository.category.deleteServingStyle(
            categoryId: category.id,
            servingStyleId: servingStyle.id
        ) {
        case .success:
            await MainActor.run {
                withAnimation {
                    servingStyles.remove(object: servingStyle)
                }
            }
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Failed to delete serving style '\(servingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
