import Components

import Extensions
import Logging
import Models
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

    private let logger = Logger(label: "SubBrandAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var name: String = ""
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
            .name != name && name
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
                await initialize(id: id)
            }
        }
        .navigationTitle("subBrand.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: subBrand)
        .toolbar {
            toolbarContent
        }
        .task(id: id) {
            if subBrand.id != id {
                await initialize(id: id)
            }
        }
    }

    @ViewBuilder private var content: some View {
        Section("subBrand.admin.section.subBrand") {
            RouterLink(open: .screen(.subBrand(brandId: subBrand.brand.id, subBrandId: subBrand.id))) {
                SubBrandView(subBrand: subBrand)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: subBrand)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "labels.name", text: $name)
            Toggle("subBrand.includesBrandName.toggle.label", isOn: $includesBrandName)
        }
        .customListRowBackground()
        Section("labels.info") {
            LabeledIdView(id: subBrand.id.rawValue.formatted())
            LabeledContent("brand.label") {
                RouterLink(subBrand.brand.name,
                           open: .sheet(.brandAdmin(id: subBrand.brand.id, onUpdate: { brand in
                               subBrand = subBrand.copyWith(brand: .init(brand: brand))
                               await onUpdate(subBrand)
                           })))
            }
            LabeledContent("brandOwner.label") {
                RouterLink(
                    subBrand.brand.brandOwner.name,
                    open: .sheet(
                        .companyAdmin(
                            id: subBrand.brand.brandOwner.id,
                            onUpdate: { company in
                                subBrand = subBrand.copyWith(brand: subBrand.brand.copyWith(brandOwner: .init(company: company)))
                                await onUpdate(subBrand)
                            }
                        )
                    )
                )
            }
            RouterLink(
                "brand.admin.product.count",
                count: subBrand.products.count,
                open: .screen(.productListAdmin(products: $subBrand.map(getter: { _ in
                    subBrand.products.map { .init(product: $0, subBrand: subBrand) }
                }, setter: { products in
                    subBrand.copyWith(products: products.map { .init(product: $0) })
                })))
            )
            VerificationAdminToggleView(isVerified: subBrand.isVerified, action: verifySubBrand)
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.editSuggestions.title",
                systemImage: "square.and.pencil",
                badge: subBrand.editSuggestions.unresolvedCount,
                open: .screen(.subBrandEditSuggestions(subBrand: $subBrand))
            )
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: subBrand.reports.count,
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

    private func initialize(id: SubBrand.Id) async {
        state = .loading
        do {
            subBrand = try await repository.subBrand.getDetailed(id: id)
            name = subBrand.name ?? ""
            includesBrandName = subBrand.includesBrandName
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $subBrand.map(getter: { subBrand in
                            subBrand.reports
                        }, setter: { reports in
                            subBrand.copyWith(reports: reports)
                        }), initialReport: id)))
                case let .editSuggestions(id):
                    router.open(.screen(.subBrandEditSuggestions(subBrand: $subBrand, initialEditSuggestion: id)))
                }
                self.open = nil
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load detailed sub-brand information. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifySubBrand(isVerified: Bool) async {
        do {
            try await repository.subBrand.verification(id: subBrand.id, isVerified: isVerified)
            subBrand = subBrand.copyWith(isVerified: isVerified)
            await onUpdate(subBrand)
            feedbackModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func editSubBrand() async {
        do {
            let updated = try await repository.subBrand.update(updateRequest: .name(.init(id: id, name: name, includesBrandName: includesBrandName)))
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
            feedbackModel.trigger(.notification(.success))
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
