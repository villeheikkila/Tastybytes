import SwiftUI
import OSLog

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
          Button("Delete", systemSymbol: .trash, role: .destructive, action: { toDeleteServingStyle = servingStyle })
        }
      }
    }
    .navigationTitle("\(category.name) Serving Styles")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(leading: Button("Done", role: .cancel, action: { dismiss() }).bold(),
                        trailing: RouterLink("Add Barcode", systemSymbol: .plus,
                                             sheet: .servingStyleManagement(
                                               pickedServingStyles: $servingStyles,
                                               onSelect: { servingStyle in
                                                 await addServingStyleToCategory(servingStyle)
                                               }
                                             )).bold())
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
      logger.error("failed to add serving style to category'. error: \(error)")
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
      logger.error("failed to delete serving style '\(servingStyle.id)'. error: \(error)")
    }
  }
}
