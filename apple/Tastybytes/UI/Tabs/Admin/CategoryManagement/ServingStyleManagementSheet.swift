import SwiftUI

struct ServingStyleManagementSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss
  @Binding var pickedServingStyles: [ServingStyle]
  let onSelect: (_ servingStyle: ServingStyle) -> Void

  init(
    _ client: Client,
    pickedServingStyles: Binding<[ServingStyle]>,
    onSelect: @escaping (_ servingStyle: ServingStyle) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _pickedServingStyles = pickedServingStyles
    self.onSelect = onSelect
  }

  var body: some View {
    NavigationStack {
      List {
        ForEach(viewModel.servingStyles) { servingStyle in
          Button(action: { onSelect(servingStyle) }, label: {
            HStack {
              Text(servingStyle.label)
              Spacer()
              if pickedServingStyles.contains(servingStyle) {
                Label("Picked serving style", systemImage: "checkmark")
                  .labelStyle(.iconOnly)
              }
            }
          })
          .swipeActions {
            Button(action: { viewModel.editServingStyle = servingStyle }, label: {
              Label("Edit", systemImage: "pencil")
            }).tint(.yellow)
            Button(role: .destructive, action: { viewModel.toDeleteServingStyle = servingStyle }, label: {
              Label("Delete", systemImage: "trash")
            })
          }
        }
        Section {
          TextField("Name", text: $viewModel.newServingStyleName)
          Button("Create") {
            viewModel.createServingStyle()
          }
          .disabled(!validateStringLength(str: viewModel.newServingStyleName, type: .normal))
        } header: {
          Text("Add new serving style")
        }
      }
      .navigationBarTitle("Pick Serving Style")
      .navigationBarItems(trailing: Button(role: .cancel, action: { dismiss() }, label: {
        Text("Done").bold()
      }))
      .alert("Edit Serving Style", isPresented: $viewModel.showEditServingStyle, actions: {
        TextField("TextField", text: $viewModel.servingStyleName)
        Button("Cancel", role: .cancel, action: {})
        Button("Edit", action: {
          viewModel.saveEditServingStyle()
        })
      })
      .confirmationDialog("Delete Serving Style",
                          isPresented: $viewModel.showDeleteServingStyleConfirmation,
                          presenting: viewModel.toDeleteServingStyle)
      { presenting in
        Button(
          "Delete \(presenting.name) serving style",
          role: .destructive,
          action: {
            viewModel.deleteServingStyle(onDelete: {
              hapticManager.trigger(of: .notification(.success))
            })
          }
        )
      }
      .task {
        viewModel.getAllServingStyles()
      }
    }
  }
}

extension ServingStyleManagementSheet {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ServingStyleManagement2Sheet")
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
      if let toDeleteServingStyle {
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
    }

    func saveEditServingStyle() {
      if let editServingStyle {
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
}
