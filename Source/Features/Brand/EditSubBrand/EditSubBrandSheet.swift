import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct EditSubBrandSheet: View {
    private let logger = Logger(category: "EditSubBrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var showMergeSubBrandsConfirmation = false
    @State private var newSubBrandName: String
    @State private var subBrand: SubBrand.JoinedProduct
    @State private var mergeTo: SubBrand.JoinedProduct? {
        didSet {
            if oldValue != nil {
                showMergeSubBrandsConfirmation = true
            } else {
                showMergeSubBrandsConfirmation = false
            }
        }
    }

    @State private var alertError: AlertError?

    let onUpdate: () async -> Void
    let brand: Brand.JoinedSubBrandsProductsCompany

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        subBrand: SubBrand.JoinedProduct,
        onUpdate: @escaping () async -> Void
    ) {
        self.brand = brand
        _subBrand = State(wrappedValue: subBrand)
        _newSubBrandName = State(wrappedValue: subBrand.name ?? "")
        self.onUpdate = onUpdate
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
            Section("subBrand.name.title") {
                TextField("subBrand.name.placeholder", text: $newSubBrandName)
                ProgressButton("labels.edit") {
                    await editSubBrand(onSuccess: { @MainActor in
                        await onUpdate()
                    })
                }
                .disabled(invalidNewName)
            }

            if !subBrandsToMergeTo.isEmpty {
                Section("subBrand.mergeToAnotherSubBrand.title") {
                    ForEach(subBrandsToMergeTo) { subBrand in
                        if let name = subBrand.name {
                            Button(name, action: { mergeTo = subBrand })
                        }
                    }
                }
            }

            if profileEnvironmentModel.hasRole(.admin) {
                Section("labels.info") {
                    LabeledContent("labels.id", value: "\(subBrand.id)")
                        .textSelection(.enabled)
                    LabeledContent("verification.verified.label", value: "\(subBrand.isVerified)".capitalized)
                }.headerProminence(.increased)
            }
        }
        .navigationTitle("labels.edit \(subBrand.name.orEmpty)")
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .confirmationDialog(
            "subBrand.mergeTo.confirmation.description",
            isPresented: $showMergeSubBrandsConfirmation,
            titleVisibility: .visible,
            presenting: mergeTo
        ) { presenting in
            ProgressButton(
                "subBrand.mergeTo.confirmation.label \(subBrand.label) \(presenting.label)",
                role: .destructive,
                action: {
                    await mergeToSubBrand(subBrand: subBrand, onSuccess: {
                        feedbackEnvironmentModel.trigger(.notification(.success))
                        await onUpdate()
                    })
                }
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneAction()
    }

    func mergeToSubBrand(subBrand: SubBrand.JoinedProduct, onSuccess: @escaping () async -> Void) async {
        guard let mergeTo else { return }
        switch await repository.subBrand
            .update(updateRequest: .brand(SubBrand.UpdateBrandRequest(id: subBrand.id, brandId: mergeTo.id)))
        {
        case .success:
            self.mergeTo = nil
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to merge to merge sub-brand '\(subBrand.id)' to '\(mergeTo.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    @Sendable func editSubBrand(onSuccess: @Sendable @escaping () async -> Void) async {
        switch await repository.subBrand
            .update(updateRequest: .name(SubBrand.UpdateNameRequest(id: subBrand.id, name: newSubBrandName)))
        {
        case .success:
            feedbackEnvironmentModel.toggle(.success("subBrand.updated.toast"))
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to edit sub-brand'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension SubBrandProtocol {
    var label: LocalizedStringKey {
        if let name {
            LocalizedStringKey(stringLiteral: name)
        } else {
            "subBrand.defaultSubBrand.label"
        }
    }
}
