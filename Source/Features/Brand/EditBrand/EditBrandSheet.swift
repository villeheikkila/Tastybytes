import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct EditBrandSheet: View {
    typealias BrandUpdateCallback = (_ updatedBrand: Brand.JoinedSubBrandsProductsCompany) async -> Void
    private let logger = Logger(category: "EditBrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var brandOwner: Company
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var newCompanyName = ""
    @State private var alertError: AlertError?
    @State private var selectedLogo: PhotosPickerItem?

    let onUpdate: BrandUpdateCallback
    let initialBrandOwner: Company

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        onUpdate: @escaping BrandUpdateCallback
    ) {
        self.onUpdate = onUpdate
        initialBrandOwner = brand.brandOwner
        _brand = State(wrappedValue: brand)
        _brandOwner = State(wrappedValue: brand.brandOwner)
        _name = State(wrappedValue: brand.name)
    }

    var body: some View {
        Form {
            Section("brand.edit.name.title") {
                TextField("brand.edit.name.placeholder", text: $name)
                ProgressButton("labels.edit") {
                    await editBrand { updatedBrand in
                        await onUpdate(updatedBrand)
                    }
                }.disabled(!name.isValidLength(.normal) || brand.name == name)
            }.headerProminence(.increased)

            Section("brand.edit.brandOwner.title") {
                RouterLink(brandOwner.name, sheet: .companySearch(onSelect: { company in
                    brandOwner = company
                }))
                ProgressButton("brand.edit.brandOwner.label") {
                    await editBrand { updatedBrand in
                        await onUpdate(updatedBrand)
                    }
                }.disabled(brandOwner.id == initialBrandOwner.id)
            }.headerProminence(.increased)

            EditLogoSection(logos: brand.logos, onUpload: { imageData in
                await uploadLogo(data: imageData)
            }, onDelete: { imageEntity in
                await deleteLogo(entity: imageEntity)
            })

            if profileEnvironmentModel.hasRole(.admin) {
                Section("labels.info") {
                    LabeledContent("labels.id", value: "\(brand.id)")
                        .textSelection(.enabled)
                    LabeledContent("verification.verified.label", value: "\(brand.isVerified)".capitalized)
                }.headerProminence(.increased)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("brand.edit.navigationTitle")
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await uploadLogo(data: data)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func editBrand(onSuccess: @escaping BrandUpdateCallback) async {
        switch await repository.brand.update(updateRequest: .init(id: brand.id, name: name, brandOwnerId: brandOwner.id)) {
        case let .success(brand):
            feedbackEnvironmentModel.toggle(.success("brand.edit.success.toast"))
            self.brand = brand
            await onSuccess(brand)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
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
            alertError = .init()
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
            alertError = .init()
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
struct EditLogoSection: View {
    private let logger = Logger(category: "EditLogoSection")
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var selectedLogo: PhotosPickerItem?

    let logos: [ImageEntity]
    let onUpload: (Data) async -> Void
    let onDelete: (ImageEntity) async -> Void

    var body: some View {
        Section {
            ForEach(logos) { logo in
                RemoteImage(url: logo.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)) { state in
                    if let image = state.image {
                        image.resizable()
                    } else {
                        ProgressView()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .accessibility(hidden: true)
                .contextMenu {
                    ProgressButton("labels.delete") {
                        await onDelete(logo)
                    }
                }
            }
        } header: {
            HStack {
                Text("logos.edit.title")
                Spacer()
                if profileEnvironmentModel.hasPermission(.canAddBrandLogo) {
                    PhotosPicker(
                        selection: $selectedLogo,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("labels.add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .headerProminence(.increased)
        .customListRowBackground()
        .task(id: selectedLogo) {
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await onUpload(data)
        }
    }
}
