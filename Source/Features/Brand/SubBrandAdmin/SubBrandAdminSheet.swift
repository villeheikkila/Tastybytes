import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct SubBrandAdminSheet: View {
    typealias UpdateSubBrandCallback = (_ subBrand: SubBrand.JoinedProduct) async -> Void

    private let logger = Logger(category: "SubBrandAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var newSubBrandName: String
    @State private var includesBrandName: Bool
    @State private var subBrand = SubBrand.Detailed()
    @State private var id: SubBrand.Id

    @Binding var brand: Brand.JoinedSubBrandsProductsCompany

    init(
        brand: Binding<Brand.JoinedSubBrandsProductsCompany>,
        subBrand: SubBrandProtocol
    ) {
        _id = State(initialValue: subBrand.id)
        _brand = brand
        _newSubBrandName = State(initialValue: subBrand.name ?? "")
        _includesBrandName = State(initialValue: subBrand.includesBrandName)
    }

    private var canUpdate: Bool {
        (subBrand
            .name != newSubBrandName && newSubBrandName
            .isValidLength(.normal(allowEmpty: false))) || includesBrandName != subBrand.includesBrandName
    }

    private var subBrandsToMergeTo: [SubBrand.JoinedProduct] {
        brand.subBrands.filter { $0.name != nil && $0.id != subBrand.id }
    }

    var body: some View {
        Form {
            content
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
            RouterLink(open: .screen(.subBrand(.init(brand: brand, subBrand: subBrand)))) {
                SubBrandEntityView(brand: brand, subBrand: subBrand)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: subBrand)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "labels.name", text: $newSubBrandName)
            Toggle("subBrand.includesBrandName.toggle.label", isOn: $includesBrandName)
        }
        .customListRowBackground()
        if !subBrandsToMergeTo.isEmpty {
            Section("subBrand.mergeToAnotherSubBrand.title") {
                ForEach(subBrandsToMergeTo) { subBrand in
                    EditSubBrandMergeToRowView(subBrand: subBrand) { mergeTo in
                        await mergeToSubBrand(mergeTo: mergeTo)
                    }
                }
            }
            .customListRowBackground()
        }
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
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.subBrand(subBrand.id))))
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
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed sub-brand information. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifySubBrand(isVerified: Bool) async {
        do {
            try await repository.subBrand.verification(id: subBrand.id, isVerified: isVerified)
            let updatedSubBrand = SubBrand.JoinedProduct(subBrand: subBrand).copyWith(
                isVerified: isVerified
            )
            subBrand = subBrand.copyWith(isVerified: isVerified)
            let updatedSubBrands = brand.subBrands.replacingWithId(id, with: updatedSubBrand)
            brand = brand.copyWith(subBrands: updatedSubBrands)
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
            withAnimation {
                brand = brand.copyWith(subBrands: brand.subBrands.removingWithId(id))
            }
            id = mergeTo.id
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
            router.open(.toast(.success("subBrand.updated.toast")))
            subBrand = subBrand.copyWith(name: updated.name, includesBrandName: includesBrandName)
            let updatedSubBrands = brand.subBrands.replacingWithId(id, with: SubBrand.JoinedProduct(subBrand: subBrand).copyWith(name: updated.name, includesBrandName: includesBrandName))
            brand = brand.copyWith(subBrands: updatedSubBrands)
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
            withAnimation {
                brand = brand.copyWith(subBrands: brand.subBrands.removingWithId(subBrand.id))
            }
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

struct SubBrandEditSuggestionsScreen: View {
    @Binding var subBrand: SubBrand.Detailed

    var body: some View {
        List(subBrand.editSuggestions) { editSuggestion in
            SubBrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        }
        .navigationTitle("subBrand.editSuggestion.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SubBrandEditSuggestionEntityView: View {
    let editSuggestion: SubBrand.EditSuggestion

    var body: some View {
        VStack {
            if let name = editSuggestion.name {
                Text(name)
            }
        }
    }
}
