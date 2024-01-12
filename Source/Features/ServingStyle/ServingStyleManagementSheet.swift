import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ServingStyleManagementSheet: View {
    private let logger = Logger(category: "ServingStyleManagementSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var servingStyles = [ServingStyle]()
    @State private var servingStyleName = ""
    @State private var newServingStyleName = ""
    @State private var alertError: AlertError?
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
                ProgressButton(
                    action: { await onSelect(servingStyle) },
                    label: {
                        HStack {
                            Text(servingStyle.label)
                            Spacer()
                            if pickedServingStyles.contains(servingStyle) {
                                Label("Picked serving style", systemImage: "checkmark")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                )
                .swipeActions {
                    Button("Edit", systemImage: "pencil", action: { editServingStyle = servingStyle }).tint(
                        .yellow)
                    Button(
                        "Delete",
                        systemImage: "trash",
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
        .alert(
            "Edit Serving Style", isPresented: $showEditServingStyle,
            actions: {
                TextField("TextField", text: $servingStyleName)
                Button("actions.cancel", role: .cancel, action: {})
                ProgressButton(
                    "Edit",
                    action: {
                        await saveEditServingStyle()
                    }
                )
            }
        )
        .confirmationDialog(
            "serving-style.delete-warning.title",
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
            withAnimation {
                self.servingStyles = servingStyles
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load all serving styles. Error: \(error) (\(#file):\(#line))")
        }
    }

    func createServingStyle() async {
        switch await repository.servingStyle.insert(
            servingStyle: ServingStyle.NewRequest(name: newServingStyleName))
        {
        case let .success(servingStyle):
            withAnimation {
                servingStyles.append(servingStyle)
                newServingStyleName = ""
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to create new serving style. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteServingStyle(_ servingStyle: ServingStyle) async {
        switch await repository.servingStyle.delete(id: servingStyle.id) {
        case .success:
            withAnimation {
                servingStyles.remove(object: servingStyle)
            }
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to delete serving style '\(servingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func saveEditServingStyle() async {
        guard let editServingStyle else { return }
        switch await repository.servingStyle
            .update(update: ServingStyle.UpdateRequest(id: editServingStyle.id, name: servingStyleName))
        {
        case let .success(servingStyle):
            withAnimation {
                servingStyles.replace(editServingStyle, with: servingStyle)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to edit '\(editServingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
