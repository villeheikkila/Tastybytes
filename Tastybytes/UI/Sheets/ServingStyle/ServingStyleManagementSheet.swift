import Model
import OSLog
import SwiftUI

struct ServingStyleManagementSheet: View {
    private let logger = Logger(category: "ServingStyleManagementSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
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

    var body: some View {
        List {
            ForEach(servingStyles) { servingStyle in
                ProgressButton(action: { await onSelect(servingStyle) }, label: {
                    HStack {
                        Text(servingStyle.label)
                        Spacer()
                        if pickedServingStyles.contains(servingStyle) {
                            Label("Picked serving style", systemSymbol: .checkmark)
                                .labelStyle(.iconOnly)
                        }
                    }
                })
                .swipeActions {
                    Button("Edit", systemSymbol: .pencil, action: { editServingStyle = servingStyle }).tint(.yellow)
                    Button(
                        "Delete",
                        systemSymbol: .trash,
                        role: .destructive,
                        action: { toDeleteServingStyle = servingStyle }
                    )
                }
            }
            Section("Add new serving style") {
                TextField("Name", text: $newServingStyleName)
                ProgressButton("Create") {
                    await createServingStyle()
                }
                .disabled(!newServingStyleName.isValidLength(.normal))
            }
        }
        .navigationBarTitle("Pick Serving Style")
        .toolbar {
            toolbarContent
        }
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
                action: { await deleteServingStyle(presenting) }
            )
        }
        .task {
            await getAllServingStyles()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }

    func getAllServingStyles() async {
        switch await repository.servingStyle.getAll() {
        case let .success(servingStyles):
            await MainActor.run {
                withAnimation {
                    self.servingStyles = servingStyles
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load all serving styles. Error: \(error) (\(#file):\(#line))")
        }
    }

    func createServingStyle() async {
        switch await repository.servingStyle.insert(servingStyle: ServingStyle.NewRequest(name: newServingStyleName)) {
        case let .success(servingStyle):
            await MainActor.run {
                withAnimation {
                    servingStyles.append(servingStyle)
                    newServingStyleName = ""
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to create new serving style. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteServingStyle(_ servingStyle: ServingStyle) async {
        switch await repository.servingStyle.delete(id: servingStyle.id) {
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

    func saveEditServingStyle() async {
        guard let editServingStyle else { return }
        switch await repository.servingStyle
            .update(update: ServingStyle.UpdateRequest(id: editServingStyle.id, name: servingStyleName))
        {
        case let .success(servingStyle):
            await MainActor.run {
                withAnimation {
                    servingStyles.replace(editServingStyle, with: servingStyle)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to edit '\(editServingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
