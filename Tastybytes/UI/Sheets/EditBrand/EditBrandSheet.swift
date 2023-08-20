import Model
import NukeUI
import OSLog
import PhotosUI
import SwiftUI

struct EditBrandSheet: View {
    private let logger = Logger(category: "EditBrandSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var brandOwner: Company
    @State private var brand: Brand.JoinedSubBrandsProductsCompany
    @State private var selectedLogo: PhotosPickerItem? {
        didSet {
            if selectedLogo != nil {
                Task { await uploadLogo() }
            }
        }
    }

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
            if profileManager.hasPermission(.canAddBrandLogo) {
                Section("Logo") {
                    PhotosPicker(
                        selection: $selectedLogo,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        if let logoUrl = brand.logoUrl {
                            LazyImage(url: logoUrl) { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 52, height: 52)
                                        .accessibility(hidden: true)
                                } else {
                                    Image(systemSymbol: .photo)
                                        .accessibility(hidden: true)
                                }
                            }
                        } else {
                            Image(systemSymbol: .photo)
                                .accessibility(hidden: true)
                        }
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
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }

    func editBrand(onSuccess: @escaping () async -> Void) async {
        switch await repository.brand
            .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
        {
        case .success:
            feedbackManager.toggle(.success("Brand updated!"))
            await onSuccess()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to edit brand'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadLogo() async {
        guard let data = await selectedLogo?.getJPEG() else { return }
        switch await repository.brand.uploadLogo(brandId: brand.id, data: data) {
        case .success:
            await onUpdate()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Uplodaing company logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
