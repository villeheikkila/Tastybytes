import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct SubBrandAdminSheet: View {
    typealias OnUpdateCallback = (_ subBrand: SubBrand.Detailed) async -> Void
    typealias OnDeleteCallback = (_ subBrand: SubBrand.Id) async -> Void

    enum Open {
        case report(Report.Id)
        case editSuggestions(SubBrand.EditSuggestion.Id)
    }

    private let logger = Logger(category: "SubBrandAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var newSubBrandName: String = ""
    @State private var includesBrandName: Bool = false
    @State private var subBrand = SubBrand.Detailed()
    @State private var id: SubBrand.Id
    @State private var open: Open?

    private let onUpdate: OnUpdateCallback
    private let onDelete: OnDeleteCallback

    init(id: SubBrand.Id, open: Open?, onUpdate: @escaping OnUpdateCallback, onDelete: @escaping OnDeleteCallback) {
        _id = State(initialValue: id)
        _open = State(initialValue: open)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    private var canUpdate: Bool {
        (subBrand
            .name != newSubBrandName && newSubBrandName
            .isValidLength(.normal(allowEmpty: false))) || includesBrandName != subBrand.includesBrandName
    }

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await loadData(id: id)
            }
        }
        .navigationTitle("subBrand.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: subBrand)
        .toolbar {
            toolbarContent
        }
        .task(id: id) {
            await loadData(id: id)
        }
    }

    @ViewBuilder private var content: some View {
        Section("subBrand.admin.section.subBrand") {
            RouterLink(open: .screen(.subBrand(.init(subBrand: subBrand)))) {
                SubBrandEntityView(subBrand: subBrand)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: subBrand)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "labels.name", text: $newSubBrandName)
            Toggle("subBrand.includesBrandName.toggle.label", isOn: $includesBrandName)
        }
        .customListRowBackground()
//        if !subBrandsToMergeTo.isEmpty {
//            Section("subBrand.mergeToAnotherSubBrand.title") {
//                ForEach(subBrandsToMergeTo) { subBrand in
//                    EditSubBrandMergeToRowView(subBrand: subBrand) { mergeTo in
//                        await mergeToSubBrand(mergeTo: mergeTo)
//                    }
//                }
//            }
//            .customListRowBackground()
//        }
        Section("labels.info") {
            LabeledIdView(id: subBrand.id.rawValue.formatted())
            LabeledContent("brand.admin.product.count", value: subBrand.products.count.formatted())
            VerificationAdminToggleView(isVerified: subBrand.isVerified, action: verifySubBrand)
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.editSuggestions.title",
                systemImage: "square.and.pencil",
                count: subBrand.editSuggestions.unresolvedCount,
                open: .screen(.subBrandEditSuggestions(subBrand: $subBrand))
            )
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                count: subBrand.reports.count,
                open: .screen(
                    .reports(reports: $subBrand.map(getter: { location in
                        location.reports
                    }, setter: { reports in
                        subBrand.copyWith(reports: reports)
                    }))
                )
            )
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: subBrand,
                action: deleteSubBrand,
                description: "subBrand.delete.disclaimer",
                label: "subBrand.delete \(subBrand.name ?? "subBrand.default.label")",
                isDisabled: subBrand.isVerified
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            AsyncButton("labels.edit") {
                await editSubBrand()
            }
            .disabled(!canUpdate)
        }
    }

    private func loadData(id: SubBrand.Id) async {
        state = .loading
        do {
            subBrand = try await repository.subBrand.getDetailed(id: id)
            newSubBrandName = subBrand.name ?? ""
            includesBrandName = subBrand.includesBrandName
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $subBrand.map(getter: { location in
                            location.reports
                        }, setter: { reports in
                            subBrand.copyWith(reports: reports)
                        }))))
                case let .editSuggestions(id):
                    router.open(.screen(.subBrandEditSuggestions(subBrand: $subBrand)))
                }
                self.open = nil
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed sub-brand information. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifySubBrand(isVerified: Bool) async {
        do {
            try await repository.subBrand.verification(id: subBrand.id, isVerified: isVerified)
            subBrand = subBrand.copyWith(isVerified: isVerified)
            await onUpdate(subBrand)
            feedbackEnvironmentModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func mergeToSubBrand(mergeTo: SubBrand.JoinedProduct) async {
        do {
            // TODO: This is completely wrong
            // try await repository.subBrand
            //    .update(updateRequest: .brand(.init(id: id, brandId: mergeTo.id)))
            id = mergeTo.id
            await onDelete(subBrand.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to merge to merge sub-brand '\(id)' to '\(mergeTo.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func editSubBrand() async {
        do {
            let updated = try await repository.subBrand.update(updateRequest: .name(.init(id: id, name: newSubBrandName, includesBrandName: includesBrandName)))
            subBrand = subBrand.copyWith(name: updated.name, includesBrandName: includesBrandName)
            await onUpdate(subBrand)
            router.open(.toast(.success("subBrand.updated.toast")))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit sub-brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteSubBrand(_ subBrand: SubBrand.Detailed) async {
        do {
            try await repository.subBrand.delete(id: subBrand.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            await onDelete(subBrand.id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error(
                "Failed to delete brand '\(subBrand.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct EditSubBrandMergeToRowView: View {
    @State private var showMergeConfirmationDialog = false
    let subBrand: SubBrand.JoinedProduct
    let onMerge: (_ mergeTo: SubBrand.JoinedProduct) async -> Void

    var body: some View {
        if let name = subBrand.name {
            Button(name, action: { showMergeConfirmationDialog = true })
                .confirmationDialog(
                    "subBrand.mergeTo.confirmation.description",
                    isPresented: $showMergeConfirmationDialog,
                    titleVisibility: .visible,
                    presenting: subBrand
                ) { presenting in
                    AsyncButton(
                        "subBrand.mergeTo.confirmation.label \(subBrand.label) \(presenting.label)",
                        role: .destructive,
                        action: {
                            await onMerge(subBrand)
                        }
                    )
                }
        }
    }
}

extension SubBrandProtocol {
    var label: String {
        if let name {
            name
        } else {
            String(localized: "subBrand.defaultSubBrand.label")
        }
    }
}
