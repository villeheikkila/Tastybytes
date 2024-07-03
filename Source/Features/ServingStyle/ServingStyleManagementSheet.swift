import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ServingStyleManagementSheet: View {
    private let logger = Logger(category: "ServingStyleManagementSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var servingStyles = [ServingStyle]()
    @State private var newServingStyleName = ""
    @Binding var pickedServingStyles: [ServingStyle]

    let onSelect: (_ servingStyle: ServingStyle) async -> Void

    var body: some View {
        List {
            ForEach(servingStyles) { servingStyle in
                ServingStyleManagementRow(servingStyle: servingStyle, pickedServingStyles: $pickedServingStyles, deleteServingStyle: deleteServingStyle, editServingStyle: editServingStyle, onSelect: onSelect)
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
        .task {
            await getAllServingStyles()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func getAllServingStyles() async {
        switch await repository.servingStyle.getAll() {
        case let .success(servingStyles):
            withAnimation {
                self.servingStyles = servingStyles
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
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
            router.open(.alert(.init()))
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
            router.open(.alert(.init()))
            logger.error("Failed to delete serving style '\(servingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func editServingStyle(_ servingStyle: ServingStyle, _ updatedServingStyle: ServingStyle) async {
        switch await repository.servingStyle
            .update(update: ServingStyle.UpdateRequest(id: updatedServingStyle.id, name: updatedServingStyle.name))
        {
        case let .success(servingStyle):
            withAnimation {
                servingStyles.replace(servingStyle, with: updatedServingStyle)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit serving style '\(servingStyle.name)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ServingStyleManagementRow: View {
    @State private var showDeleteServingStyleConfirmation = false
    @State private var servingStyleName = ""
    @State private var showEditServingStyle = false {
        didSet {
            servingStyleName = servingStyle.name
        }
    }

    let servingStyle: ServingStyle
    @Binding var pickedServingStyles: [ServingStyle]
    let deleteServingStyle: (_ servingStyle: ServingStyle) async -> Void
    let editServingStyle: (_ servingStyle: ServingStyle, _ updatedServingStyle: ServingStyle) async -> Void
    let onSelect: (_ servingStyle: ServingStyle) async -> Void

    var body: some View {
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
            Button("labels.edit", systemImage: "pencil", action: { showEditServingStyle = true }).tint(
                .yellow)
            Button(
                "labels.delete",
                systemImage: "trash",
                role: .destructive,
                action: { showDeleteServingStyleConfirmation = true }
            )
        }
        .confirmationDialog(
            "servingStyle.deleteConfirmation.title",
            isPresented: $showDeleteServingStyleConfirmation,
            titleVisibility: .visible,
            presenting: servingStyle
        ) { presenting in
            ProgressButton(
                "servingStyle.deleteConfirmation.label \(presenting.name)",
                role: .destructive,
                action: { await deleteServingStyle(presenting) }
            )
        }
        .alert(
            "servingStyle.name.edit.title", isPresented: $showEditServingStyle,
            actions: {
                TextField("servingStyle.name.placeholder", text: $servingStyleName)
                Button("labels.cancel", role: .cancel, action: {})
                ProgressButton(
                    "labels.edit",
                    action: {
                        await editServingStyle(servingStyle, servingStyle.copyWith(name: $servingStyleName.wrappedValue))
                    }
                )
            }
        )
    }
}
