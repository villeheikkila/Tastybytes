import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct BrandAdminSheet: View {
    typealias BrandUpdateCallback = (_ updatedBrand: Brand.JoinedSubBrandsProductsCompany) async -> Void
    private let logger = Logger(category: "BrandAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteBrandConfirmationDialog = false
    @State private var name: String
    @State private var brandOwner: Company
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var newCompanyName = ""
    @State private var selectedLogo: PhotosPickerItem?

    let onUpdate: BrandUpdateCallback
    let onDelete: BrandUpdateCallback
    let initialBrandOwner: Company

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        onUpdate: @escaping BrandUpdateCallback,
        onDelete: @escaping BrandUpdateCallback
    ) {
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        initialBrandOwner = brand.brandOwner
        _brand = State(wrappedValue: brand)
        _brandOwner = State(wrappedValue: brand.brandOwner)
        _name = State(wrappedValue: brand.name)
    }

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("brand.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await loadData()
        }
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await uploadLogo(data: data)
        }
    }

    @ViewBuilder private var content: some View {
        Section("brand.admin.section.brand") {
            RouterLink(open: .screen(.brand(brand))) {
                BrandEntityView(brand: brand)
            }
        }
        CreationInfoSection(createdBy: brand.createdBy, createdAt: brand.createdAt)
        Section("admin.section.details") {
            LabeledTextField(title: "brand.admin.changeName.label", text: $name)
            LabeledContent("brand.admin.changeBrandOwner.label") {
                RouterLink(brandOwner.name, open: .sheet(.companySearch(onSelect: { company in
                    brandOwner = company
                })))
            }
        }
        EditLogoSection(logos: brand.logos, onUpload: uploadLogo, onDelete: deleteLogo)
        Section("labels.info") {
            LabeledIdView(id: brand.id.formatted())
            LabeledContent("brand.admin.subBrand.count", value: brand.subBrands.count.formatted())
            LabeledContent("brand.admin.products.count", value: brand.subBrands.reduce(0, { result, subBrand in
                result + subBrand.products.count
            }).formatted())
            VerificationAdminToggleView(isVerified: brand.isVerified, action: verifyBrand)
        }
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.brand(brand.id))))
        }
        Section {
            ConfirmedDeleteButtonView(
                presenting: brand,
                action: deleteBrand,
                description: "brand.delete.disclaimer",
                label: "brand.delete.label \(brand.name)",
                isDisabled: brand.isVerified
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.edit") {
                await editBrand()
            }.disabled((!name.isValidLength(.normal) || brand.name == name) && brandOwner.id == initialBrandOwner.id)
        }
    }

    func loadData() async {
        switch await repository.brand.getDetailed(id: brand.id) {
        case let .success(brand):
            self.brand = brand
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to load detailed brand info. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyBrand(isVerified: Bool) async {
        switch await repository.brand.verification(id: brand.id, isVerified: isVerified) {
        case .success:
            brand = brand.copyWith(isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func editBrand() async {
        switch await repository.brand.update(updateRequest: .init(id: brand.id, name: name, brandOwnerId: brandOwner.id)) {
        case let .success(brand):
            router.open(.toast(.success("brand.edit.success.toast")))
            self.brand = brand
            await onUpdate(brand)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo(data: Data) async {
        switch await repository.brand.uploadLogo(brandId: brand.id, data: data) {
        case let .success(imageEntity):
            withAnimation {
                brand = brand.copyWith(logos: brand.logos + [imageEntity])
            }
            logger.info("Succesfully uploaded logo \(imageEntity.file)")
            await onUpdate(brand)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading of a brand logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLogo(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .brandLogos, entity: entity) {
        case .success:
            withAnimation {
                brand = brand.copyWith(logos: brand.logos.removing(entity))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
        switch await repository.brand.delete(id: brand.id) {
        case .success:
            await onDelete(brand)
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete brand. Error: \(error) (\(#file):\(#line))")
        }
    }
}
