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
    @State private var showDeleteConfirmation = false
    @State private var newSubBrandName: String
    @State private var subBrand: SubBrand.JoinedProduct

    let onUpdate: UpdateSubBrandCallback
    let onDelete: UpdateSubBrandCallback
    let brand: Brand.JoinedSubBrandsProductsCompany

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        subBrand: SubBrand.JoinedProduct,
        onUpdate: @escaping UpdateSubBrandCallback,
        onDelete: @escaping UpdateSubBrandCallback
    ) {
        self.brand = brand
        _subBrand = State(wrappedValue: subBrand)
        _newSubBrandName = State(wrappedValue: subBrand.name ?? "")
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var invalidNewName: Bool {
        !newSubBrandName.isValidLength(.normal) || subBrand
            .name == newSubBrandName
    }

    var subBrandsToMergeTo: [SubBrand.JoinedProduct] {
        brand.subBrands.filter { $0.name != nil && $0.id != subBrand.id }
    }

    var body: some View {
        Form {
            Section {
                RouterLink(open: .screen(.subBrand(.init(brand: brand, subBrand: subBrand)))) {
                    SubBrandEntityView(brand: brand, subBrand: subBrand)
                }
            }

            Section("subBrand.name.title") {
                TextField("subBrand.name.placeholder", text: $newSubBrandName)
            }

            if !subBrandsToMergeTo.isEmpty {
                Section("subBrand.mergeToAnotherSubBrand.title") {
                    ForEach(subBrandsToMergeTo) { subBrand in
                        EditSubBrandMergeToRowView(subBrand: subBrand) { mergeTo in
                            await mergeToSubBrand(mergeTo: mergeTo)
                        }
                    }
                }
            }

            if profileEnvironmentModel.hasRole(.admin) {
                Section("labels.info") {
                    LabeledContent("labels.id", value: "\(subBrand.id)")
                        .textSelection(.enabled)
                    LabeledContent("verification.verified.label", value: "\(subBrand.isVerified)".capitalized)
                }
            }

            if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
                Section {
                    Button(
                        "labels.delete",
                        systemImage: "trash.fill",
                        role: .destructive,
                        action: { showDeleteConfirmation = true }
                    )
                    .foregroundColor(.red)
                    .disabled(subBrand.isVerified)
                }
                .confirmationDialog(
                    "subBrand.delete.disclaimer",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible,
                    presenting: subBrand
                ) { presenting in
                    ProgressButton(
                        "subBrand.delete \(presenting.name ?? "subBrand.default.label")",
                        role: .destructive,
                        action: {
                            await deleteSubBrand(presenting)
                        }
                    )
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("subBrand.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.edit") {
                await editSubBrand()
            }
            .disabled(invalidNewName)
        }
    }

    func mergeToSubBrand(mergeTo: SubBrand.JoinedProduct) async {
        switch await repository.subBrand
            .update(updateRequest: .brand(SubBrand.UpdateBrandRequest(id: subBrand.id, brandId: mergeTo.id)))
        {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await onUpdate(subBrand)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to merge to merge sub-brand '\(subBrand.id)' to '\(mergeTo.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func editSubBrand() async {
        switch await repository.subBrand.update(updateRequest: .name(.init(id: subBrand.id, name: newSubBrandName))) {
        case let .success(updatedSubBrand):
            router.open(.toast(.success("subBrand.updated.toast")))
            let updatedSubBrand = subBrand.copyWith(name: updatedSubBrand.name)
            await onUpdate(updatedSubBrand)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit sub-brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteSubBrand(_ subBrand: SubBrand.JoinedProduct) async {
        switch await repository.subBrand.delete(id: subBrand.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await onDelete(subBrand)
            dismiss()
        case let .failure(error):
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
                    ProgressButton(
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
