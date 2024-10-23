import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ServingStyleManagementSheet: View {
    private let logger = Logger(label: "ServingStyleManagementSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackModel.self) private var feedbackModel
    @State private var servingStyles = [ServingStyle.Saved]()
    @State private var newServingStyleName = ""
    @Binding var pickedServingStyles: [ServingStyle.Saved]

    let onSelect: (_ servingStyle: ServingStyle.Saved) async -> Void

    var body: some View {
        List {
            ForEach(servingStyles) { servingStyle in
                ServingStyleManagementRow(servingStyle: servingStyle, pickedServingStyles: $pickedServingStyles, deleteServingStyle: deleteServingStyle, editServingStyle: editServingStyle, onSelect: onSelect)
            }
            Section("servingStyle.name.add.title") {
                TextField("servingStyle.name.placeholder", text: $newServingStyleName)
                AsyncButton("labels.create") {
                    await createServingStyle(name: newServingStyleName)
                }
                .disabled(!newServingStyleName.isValidLength(.normal(allowEmpty: false)))
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
        do {
            let servingStyles = try await repository.servingStyle.getAll()
            withAnimation {
                self.servingStyles = servingStyles
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to load all serving styles. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func createServingStyle(name: String) async {
        do {
            let servingStyle = try await repository.servingStyle.insert(name: name)
            withAnimation {
                servingStyles.append(servingStyle)
                newServingStyleName = ""
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to create new serving style. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteServingStyle(_ servingStyle: ServingStyle.Saved) async {
        do {
            try await repository.servingStyle.delete(id: servingStyle.id)
            withAnimation {
                servingStyles.remove(object: servingStyle)
            }
            feedbackModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete serving style '\(servingStyle.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func editServingStyle(_ servingStyle: ServingStyle.Saved, _ updatedServingStyle: ServingStyle.Saved) async {
        do {
            let servingStyle = try await repository.servingStyle
                .update(id: updatedServingStyle.id, name: updatedServingStyle.name)
            withAnimation {
                servingStyles.replace(servingStyle, with: updatedServingStyle)
            }
        } catch {
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

    let servingStyle: ServingStyle.Saved
    @Binding var pickedServingStyles: [ServingStyle.Saved]
    let deleteServingStyle: (_ servingStyle: ServingStyle.Saved) async -> Void
    let editServingStyle: (_ servingStyle: ServingStyle.Saved, _ updatedServingStyle: ServingStyle.Saved) async -> Void
    let onSelect: (_ servingStyle: ServingStyle.Saved) async -> Void

    var body: some View {
        AsyncButton(
            action: { await onSelect(servingStyle) },
            label: {
                HStack {
                    ServingStyleView(servingStyle: servingStyle)
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
                action: { showDeleteServingStyleConfirmation = true }
            )
            .tint(.red)
        }
        .confirmationDialog(
            "servingStyle.deleteConfirmation.title",
            isPresented: $showDeleteServingStyleConfirmation,
            titleVisibility: .visible,
            presenting: servingStyle
        ) { presenting in
            AsyncButton(
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
                AsyncButton(
                    "labels.edit",
                    action: {
                        await editServingStyle(servingStyle, servingStyle.copyWith(name: $servingStyleName.wrappedValue))
                    }
                )
            }
        )
    }
}
