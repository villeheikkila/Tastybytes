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
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var showDeleteBrandConfirmationDialog = false
    @State private var name: String
    @State private var brandOwner: Company
    @State private var brand: Brand.Detailed?
    @State private var newCompanyName = ""
    @State private var selectedLogo: PhotosPickerItem?

    let id: Int

    let onUpdate: BrandUpdateCallback
    let onDelete: BrandUpdateCallback

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        onUpdate: @escaping BrandUpdateCallback,
        onDelete: @escaping BrandUpdateCallback
    ) {
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        id = brand.id
        _brandOwner = State(wrappedValue: brand.brandOwner)
        _name = State(wrappedValue: brand.name)
    }

    private var isValidNameUpdate: Bool {
        name.isValidLength(.normal(allowEmpty: false)) && brand?.name != name
    }

    private var canUpdate: Bool {
        if let brand {
            isValidNameUpdate && brandOwner.id != brand.brandOwner.id
        } else {
            false
        }
    }

    var body: some View {
        Form {
            if let brand {
                content(brand: brand)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("brand.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await loadData()
            }
        }
        .toolbar {
            toolbarContent
        }
        .task {
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

    @ViewBuilder private func content(brand: Brand.Detailed) -> some View {
        Section("brand.admin.section.brand") {
            RouterLink(open: .screen(.brand(.init(brand: brand)))) {
                BrandEntityView(brand: brand)
            }
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: brand.createdBy, createdAt: brand.createdAt)
        Section("admin.section.details") {
            LabeledTextFieldView(title: "brand.admin.changeName.label", text: $name)
            LabeledContent("brand.admin.changeBrandOwner.label") {
                RouterLink(brandOwner.name, open: .sheet(.companySearch(onSelect: { company in
                    brandOwner = company
                })))
            }
        }
        .customListRowBackground()
        EditLogoSection(logos: brand.logos, onUpload: uploadLogo, onDelete: deleteLogo)
        Section("labels.info") {
            LabeledIdView(id: brand.id.formatted())
            LabeledContent("brand.admin.subBrand.count", value: brand.subBrands.count.formatted())
            LabeledContent("brand.admin.products.count", value: brand.subBrands.reduce(0) { result, subBrand in
                result + subBrand.products.count
            }.formatted())
            VerificationAdminToggleView(isVerified: brand.isVerified, action: verifyBrand)
        }
        .customListRowBackground()
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.brand(brand.id))))
            RouterLink(open: .screen(.brandEditSuggestionAdmin(brand: $brand))) {
                HStack {
                    Label("admin.section.editSuggestions.title", systemImage: "square.and.pencil")
                    Spacer()
                    Text("(\(brand.editSuggestions.unresolvedCount.formatted()))")
                }
            }
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: brand,
                action: deleteBrand,
                description: "brand.delete.disclaimer",
                label: "brand.delete.label \(brand.name)",
                isDisabled: brand.isVerified
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        if let brand {
            ToolbarItem(placement: .primaryAction) {
                AsyncButton("labels.edit") {
                    await editBrand(brand: brand)
                }
                .disabled(!canUpdate)
            }
        }
    }

    private func loadData() async {
        do {
            brand = try await repository.brand.getDetailed(id: id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed brand info. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyBrand(isVerified: Bool) async {
        guard let brand else { return }
        do {
            try await repository.brand.verification(id: brand.id, isVerified: isVerified)
            self.brand = brand.copyWith(isVerified: isVerified)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func editBrand(brand: Brand.Detailed) async {
        do {
            let brand = try await repository.brand.update(updateRequest: .init(id: id, name: isValidNameUpdate ? name : brand.name, brandOwnerId: brandOwner.id))
            router.open(.toast(.success("brand.edit.success.toast")))
            self.brand = brand
            await onUpdate(.init(brand: brand))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to edit brand. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func uploadLogo(data: Data) async {
        guard let brand else { return }
        do {
            let imageEntity = try await repository.brand.uploadLogo(brandId: brand.id, data: data)
            withAnimation {
                self.brand = brand.copyWith(logos: brand.logos + [imageEntity])
            }
            logger.info("Succesfully uploaded logo \(imageEntity.file)")
            await onUpdate(.init(brand: brand))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Uploading of a brand logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLogo(entity: ImageEntity) async {
        guard let brand else { return }
        do {
            try await repository.imageEntity.delete(from: .brandLogos, entity: entity)
            withAnimation {
                self.brand = brand.copyWith(logos: brand.logos.removing(entity))
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteBrand(_ brand: Brand.Detailed) async {
        do {
            try await repository.brand.delete(id: brand.id)
            await onDelete(.init(brand: brand))
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete brand. Error: \(error) (\(#file):\(#line))")
        }
    }
}
