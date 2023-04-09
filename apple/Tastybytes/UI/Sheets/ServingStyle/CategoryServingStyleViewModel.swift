import SwiftUI

extension CategoryServingStyleSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ServingStyleManagementSheet")
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

    func addServingStyleToCategory(_ servingStyle: ServingStyle) {
      Task {
        switch await client.category.addServingStyle(
          categoryId: category.id,
          servingStyleId: servingStyle.id
        ) {
        case .success:
          withAnimation {
            servingStyles.append(servingStyle)
          }
        case let .failure(error):
          logger
            .error(
              "failed to add serving style '\(servingStyle.id) to \(self.category.id) category': \(error.localizedDescription)"
            )
        }
      }
    }

    func deleteServingStyle(onDelete: @escaping () -> Void) {
      guard let toDeleteServingStyle else { return }
      Task {
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
          logger
            .error(
              "failed to delete serving style '\(toDeleteServingStyle.id)': \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
