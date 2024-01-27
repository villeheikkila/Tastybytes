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
    private let logger = Logger(category: "EditBrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var brandOwner: Company
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var newCompanyName = ""
    @State private var alertError: AlertError?
    @State private var selectedLogo: PhotosPickerItem?

    let onUpdate: () async -> Void
    let initialBrandOwner: Company

    init(
        brand: Brand.JoinedSubBrandsProductsCompany,
        onUpdate: @escaping () async -> Void
    ) {
        self.onUpdate = onUpdate
        initialBrandOwner = brand.brandOwner
        _brand = State(wrappedValue: brand)
        _brandOwner = State(wrappedValue: brand.brandOwner)
        _name = State(wrappedValue: brand.name)
    }

    var body: some View {
        Form {
            if profileEnvironmentModel.hasPermission(.canAddBrandLogo) {
                Section("Logo") {
                    PhotosPicker(
                        selection: $selectedLogo,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        BrandLogo(brand: brand, size: 52)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section("Brand name") {
                TextField("Name", text: $name)
                ProgressButton("Edit") {
                    await editBrand {
                        await onUpdate()
                    }
                }.disabled(!name.isValidLength(.normal) || brand.name == name)
            }

            Section("Brand Owner") {
                RouterLink(brandOwner.name, sheet: .companySearch(onSelect: { company in
                    brandOwner = company
                }))
                ProgressButton("Change brand owner") {
                    await editBrand {
                        await onUpdate()
                    }
                }.disabled(brandOwner.id == initialBrandOwner.id)
            }
        }
        .navigationTitle("Edit Brand")
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
        ToolbarDoneAction()
    }

    func editBrand(onSuccess: @escaping () async -> Void) async {
        switch await repository.brand
            .update(updateRequest: .init(id: brand.id, name: name, brandOwnerId: brandOwner.id))
        {
        case .success:
            feedbackEnvironmentModel.toggle(.success("Brand updated!"))
            await onSuccess()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to edit brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo(data: Data) async {
        switch await repository.brand.uploadLogo(brandId: brand.id, data: data) {
        case let .success(imageEntity):
            brand = brand.copyWith(logos: brand.logos + [imageEntity])
            logger.info("Succesfully uploaded logo \(imageEntity.file)")
            await onUpdate()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Uplodaing company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
