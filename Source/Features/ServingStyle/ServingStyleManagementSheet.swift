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
    @State private var toDeleteServingStyle: ServingStyle?

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
                                Label("servingStyle.selected.label", systemImage: "checkmark")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                )
                .swipeActions {
                    Button("labels.edit", systemImage: "pencil", action: { editServingStyle = servingStyle }).tint(
                        .yellow)
                    Button(
                        "labels.delete",
                        systemImage: "trash",
                        role: .destructive,
                        action: { toDeleteServingStyle = servingStyle }
                    )
                }
            }
            Section("servingStyle.name.add.title") {
                TextField("servingStyle.name.placeholder", text: $newServingStyleName)
                ProgressButton("labels.create") {
                    await createServingStyle()
                }
                .disabled(!newServingStyleName.isValidLength(.normal))
            }
        }
        .navigationBarTitle("servingStyle.picker.navigationTitle")
        .toolbar {
            toolbarContent
        }
        .alert(
            "servingStyle.name.edit.title", isPresented: $showEditServingStyle,
            actions: {
                TextField("servingStyle.name.placeholder", text: $servingStyleName)
                Button("labels.cancel", role: .cancel, action: {})
                ProgressButton(
                    "labels.edit",
                    action: {
                        await saveEditServingStyle()
                    }
                )
            }
        )
        .confirmationDialog(
            "servingStyle.deleteConfirmation.title",
            isPresented: $toDeleteServingStyle.isNotNull(),
            titleVisibility: .visible,
            presenting: toDeleteServingStyle
        ) { presenting in
            ProgressButton(
                "servingStyle.deleteConfirmation.label \(presenting.name)",
                role: .destructive,
                action: { await deleteServingStyle(presenting) }
            )
        }
        .task {
            await getAllServingStyles()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneActionView()
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
