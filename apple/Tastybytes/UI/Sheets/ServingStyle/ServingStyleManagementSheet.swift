import SwiftUI

struct ServingStyleManagementSheet: View {
  private let logger = getLogger(category: "ServingStyleManagementSheet")
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss
  @State private var servingStyles = [ServingStyle]()
  @State private var servingStyleName = ""
  @State private var newServingStyleName = ""
  @State private var toDeleteServingStyle: ServingStyle? {
    didSet {
      showDeleteServingStyleConfirmation = true
    }
  }

  @State private var showDeleteServingStyleConfirmation = false
  @State private var editServingStyle: ServingStyle? {
    didSet {
      showEditServingStyle = true
      servingStyleName = editServingStyle?.name ?? ""
    }
  }

  @State private var showEditServingStyle = false
  @Binding var pickedServingStyles: [ServingStyle]

  let onSelect: (_ servingStyle: ServingStyle) async -> Void
  let client: Client

  init(
    _ client: Client,
    pickedServingStyles: Binding<[ServingStyle]>,
    onSelect: @escaping (_ servingStyle: ServingStyle) async -> Void
  ) {
    self.client = client
    _pickedServingStyles = pickedServingStyles
    self.onSelect = onSelect
  }

  var body: some View {
    List {
      ForEach(servingStyles) { servingStyle in
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
          Button("Edit", systemImage: "pencil", action: { editServingStyle = servingStyle }).tint(.yellow)
          Button("Delete", systemImage: "trash", role: .destructive, action: { toDeleteServingStyle = servingStyle })
        }
      }
      Section {
        TextField("Name", text: $newServingStyleName)
        ProgressButton("Create") {
          await createServingStyle()
        }
        .disabled(!newServingStyleName.isValidLength(.normal))
      } header: {
        Text("Add new serving style")
      }
    }
    .navigationBarTitle("Pick Serving Style")
    .navigationBarItems(trailing: Button("Done", role: .cancel, action: { dismiss() }).bold())
    .alert("Edit Serving Style", isPresented: $showEditServingStyle, actions: {
      TextField("TextField", text: $servingStyleName)
      Button("Cancel", role: .cancel, action: {})
      ProgressButton("Edit", action: {
        await saveEditServingStyle()
      })
    })
    .confirmationDialog(
      "Are you sure you want to delete the serving style? The serving style information for affected check-ins will be permanently lost",
      isPresented: $showDeleteServingStyleConfirmation,
      titleVisibility: .visible,
      presenting: toDeleteServingStyle
    ) { presenting in
      ProgressButton(
        "Delete \(presenting.name)",
        role: .destructive,
        action: {
          await deleteServingStyle(onDelete: {
            hapticManager.trigger(.notification(.success))
          })
        }
      )
    }
    .task {
      await getAllServingStyles()
    }
  }

  func getAllServingStyles() async {
    switch await client.servingStyle.getAll() {
    case let .success(servingStyles):
      withAnimation {
        self.servingStyles = servingStyles
      }
    case let .failure(error):
      logger.error("failed to load all serving styles: \(error.localizedDescription)")
    }
  }

  func createServingStyle() async {
    switch await client.servingStyle.insert(servingStyle: ServingStyle.NewRequest(name: newServingStyleName)) {
    case let .success(servingStyle):
      withAnimation {
        servingStyles.append(servingStyle)
        newServingStyleName = ""
      }
    case let .failure(error):
      logger.error("failed to create new serving style: \(error.localizedDescription)")
    }
  }

  func deleteServingStyle(onDelete: @escaping () -> Void) async {
    guard let toDeleteServingStyle else { return }
    switch await client.servingStyle.delete(id: toDeleteServingStyle.id) {
    case .success:
      withAnimation {
        servingStyles.remove(object: toDeleteServingStyle)
      }
      onDelete()
    case let .failure(error):
      logger.error("failed to delete serving style '\(toDeleteServingStyle.id)': \(error.localizedDescription)")
    }
  }

  func saveEditServingStyle() async {
    guard let editServingStyle else { return }
    switch await client.servingStyle
      .update(update: ServingStyle.UpdateRequest(id: editServingStyle.id, name: servingStyleName))
    {
    case let .success(servingStyle):
      withAnimation {
        servingStyles.replace(editServingStyle, with: servingStyle)
      }
    case let .failure(error):
      logger.error("failed to edit '\(editServingStyle.id)': \(error.localizedDescription)")
    }
  }
}
