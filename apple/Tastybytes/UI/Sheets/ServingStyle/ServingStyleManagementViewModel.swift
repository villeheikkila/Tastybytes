import SwiftUI

extension ServingStyleManagementSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ServingStyleManagementSheet")
    let client: Client
    @Published var servingStyles = [ServingStyle]()
    @Published var servingStyleName = ""
    @Published var newServingStyleName = ""
    @Published var toDeleteServingStyle: ServingStyle? {
      didSet {
        showDeleteServingStyleConfirmation = true
      }
    }

    @Published var showDeleteServingStyleConfirmation = false
    @Published var editServingStyle: ServingStyle? {
      didSet {
        showEditServingStyle = true
        servingStyleName = editServingStyle?.name ?? ""
      }
    }

    @Published var showEditServingStyle = false

    init(_ client: Client) {
      self.client = client
    }

    func getAllServingStyles() {
      Task {
        switch await client.servingStyle.getAll() {
        case let .success(servingStyles):
          withAnimation {
            self.servingStyles = servingStyles
          }
        case let .failure(error):
          logger
            .error(
              "failed to create new serving style with name \(self.newServingStyleName): \(error.localizedDescription)"
            )
        }
      }
    }

    func createServingStyle() {
      Task {
        switch await client.servingStyle.insert(servingStyle: ServingStyle.NewRequest(name: newServingStyleName)) {
        case let .success(servingStyle):
          withAnimation {
            servingStyles.append(servingStyle)
            newServingStyleName = ""
          }
        case let .failure(error):
          logger
            .error(
              "failed to create new serving style with name \(self.newServingStyleName): \(error.localizedDescription)"
            )
        }
      }
    }

    func deleteServingStyle(onDelete: @escaping () -> Void) {
      guard let toDeleteServingStyle else { return }
      Task {
        switch await client.servingStyle.delete(id: toDeleteServingStyle.id) {
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

    func saveEditServingStyle() {
      guard let editServingStyle else { return }
      Task {
        switch await client.servingStyle
          .update(update: ServingStyle.UpdateRequest(id: editServingStyle.id, name: servingStyleName))
        {
        case let .success(servingStyle):
          withAnimation {
            servingStyles.replace(editServingStyle, with: servingStyle)
          }
        case let .failure(error):
          logger
            .error(
              "failed to edit '\(editServingStyle.id) with name \(self.servingStyleName)': \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
