import SwiftUI

struct ServingStyleManagementSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss
  @Binding var pickedServingStyles: [ServingStyle]
  let onSelect: (_ servingStyle: ServingStyle) async -> Void

  init(
    _ client: Client,
    pickedServingStyles: Binding<[ServingStyle]>,
    onSelect: @escaping (_ servingStyle: ServingStyle) async -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _pickedServingStyles = pickedServingStyles
    self.onSelect = onSelect
  }

  var body: some View {
    List {
      ForEach(viewModel.servingStyles) { servingStyle in
        ProgressButton(action: { await onSelect(servingStyle) }, label: {
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
          Button("Edit", systemImage: "pencil", action: { viewModel.editServingStyle = servingStyle }).tint(.yellow)
          Button("Delete", systemImage: "trash", role: .destructive, action: { viewModel.toDeleteServingStyle = servingStyle })
        }
      }
      Section {
        TextField("Name", text: $viewModel.newServingStyleName)
        ProgressButton("Create") {
          await viewModel.createServingStyle()
        }
        .disabled(!viewModel.newServingStyleName.isValidLength(.normal))
      } header: {
        Text("Add new serving style")
      }
    }
    .navigationBarTitle("Pick Serving Style")
    .navigationBarItems(trailing: Button("Done", role: .cancel, action: { dismiss() }).bold())
    .alert("Edit Serving Style", isPresented: $viewModel.showEditServingStyle, actions: {
      TextField("TextField", text: $viewModel.servingStyleName)
      Button("Cancel", role: .cancel, action: {})
      ProgressButton("Edit", action: {
        await viewModel.saveEditServingStyle()
      })
    })
    .confirmationDialog(
      "Are you sure you want to delete the serving style? The serving style information for affected check-ins will be permanently lost",
      isPresented: $viewModel.showDeleteServingStyleConfirmation,
      titleVisibility: .visible,
      presenting: viewModel.toDeleteServingStyle
    ) { presenting in
      ProgressButton(
        "Delete \(presenting.name)",
        role: .destructive,
        action: {
          await viewModel.deleteServingStyle(onDelete: {
            hapticManager.trigger(.notification(.success))
          })
        }
      )
    }
    .task {
      await viewModel.getAllServingStyles()
    }
  }
}
