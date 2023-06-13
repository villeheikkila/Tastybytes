import OSLog
import SwiftUI

struct CategoryServingStyleSheet: View {
    private let logger = Logger(category: "CategoryServingStyleSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(\.dismiss) private var dismiss
    @State private var servingStyles: [ServingStyle]
    @State private var showDeleteServingStyleConfirmation = false
    @State private var toDeleteServingStyle: ServingStyle? {
        didSet {
            showDeleteServingStyleConfirmation = true
        }
    }

    let category: Category.JoinedSubcategoriesServingStyles

    init(category: Category.JoinedSubcategoriesServingStyles) {
        self.category = category
        _servingStyles = State(wrappedValue: category.servingStyles)
    }

    var body: some View {
        List {
            ForEach(servingStyles) { servingStyle in
                HStack {
                    Text(servingStyle.label)
                }
                .swipeActions {
                    Button(
                        "Delete",
                        systemSymbol: .trash,
                        role: .destructive,
                        action: { toDeleteServingStyle = servingStyle }
                    )
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
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
                systemSymbol: .plus,
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
            feedbackManager.toggle(.error(.unexpected))
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
            feedbackManager.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete serving style '\(servingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}