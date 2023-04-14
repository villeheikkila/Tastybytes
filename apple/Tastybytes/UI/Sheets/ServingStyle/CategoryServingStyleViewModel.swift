import SwiftUI

extension CategoryServingStyleSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CategoryServingStyleSheet")
    let client: Client
    let category: Category.JoinedSubcategoriesServingStyles
    @Published var servingStyles: [ServingStyle]
    @Published var toDeleteServingStyle: ServingStyle? {
      didSet {
        showDeleteServingStyleConfirmation = true
      }
    }

    @Published var showDeleteServingStyleConfirmation = false

    init(_ client: Client, category: Category.JoinedSubcategoriesServingStyles) {
      self.client = client
      self.category = category
      servingStyles = category.servingStyles
    }

    func addServingStyleToCategory(_ servingStyle: ServingStyle) async {
      switch await client.category.addServingStyle(
        categoryId: category.id,
        servingStyleId: servingStyle.id
      ) {
      case .success:
        withAnimation {
          servingStyles.append(servingStyle)
        }
      case let .failure(error):
        logger.error("failed to add serving style to category': \(error.localizedDescription)")
      }
    }

    func deleteServingStyle(onDelete: @escaping () -> Void) async {
      guard let toDeleteServingStyle else { return }
      switch await client.category.deleteServingStyle(
        categoryId: category.id,
        servingStyleId: toDeleteServingStyle.id
      ) {
      case .success:
        withAnimation {
          servingStyles.remove(object: toDeleteServingStyle)
        }
        onDelete()
      case let .failure(error):
        logger.error("failed to delete serving style '\(toDeleteServingStyle.id)': \(error.localizedDescription)")
      }
    }
  }
}
