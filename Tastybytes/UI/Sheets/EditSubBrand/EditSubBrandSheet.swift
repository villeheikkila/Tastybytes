import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

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
            Section("Name") {
                TextField("Name", text: $newSubBrandName)
                ProgressButton("Edit") {
                    await editSubBrand(onSuccess: {
                        await onUpdate()
                    })
                }
                .disabled(invalidNewName)
            }

            if !subBrandsToMergeTo.isEmpty {
                Section("Merge to another sub-brand") {
                    ForEach(subBrandsToMergeTo) { subBrand in
                        if let name = subBrand.name {
                            Button(name, action: { mergeTo = subBrand })
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit \(subBrand.name.orEmpty)")
        .toolbar {
            toolbarContent
        }
        .confirmationDialog(
            "Are you sure you want to merge sub-brands? The merged sub-brand will be permanently deleted",
            isPresented: $showMergeSubBrandsConfirmation,
            titleVisibility: .visible,
            presenting: mergeTo
        ) { presenting in
            ProgressButton(
                "Merge \(subBrand.name ?? "default sub-brand") to \(presenting.name ?? "default sub-brand")",
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
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
        }
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
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger
                .error(
                    "Failed to merge to merge sub-brand '\(subBrand.id)' to '\(mergeTo.id)'. Error: \(error) (\(#file):\(#line))"
                )
        }
    }

    func editSubBrand(onSuccess: @escaping () async -> Void) async {
        switch await repository.subBrand
            .update(updateRequest: .name(SubBrand.UpdateNameRequest(id: subBrand.id, name: newSubBrandName)))
        {
        case .success:
            feedbackEnvironmentModel.toggle(.success("Sub-brand updated!"))
            await onSuccess()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to edit sub-brand'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
