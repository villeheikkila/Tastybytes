import AlertToast
import CachedAsyncImage
import PhotosUI
import SwiftUI

struct EditBrandSheet: View {
  private let logger = getLogger(category: "EditBrandSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Environment(\.dismiss) private var dismiss
  @State private var name: String
  @State private var brandOwner: Company
  @State private var showToast = false
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
              CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 52, height: 52)
                  .accessibility(hidden: true)
              } placeholder: {
                Image(systemName: "photo")
                  .accessibility(hidden: true)
              }
            } else {
              Image(systemName: "photo")
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
        RouterLink(brandOwner.name, sheet: .companySearch(onSelect: { company, _ in
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
    .navigationBarItems(trailing: Button("Done", action: { dismiss() }).bold())
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Brand updated!")
    }
  }

  func editBrand(onSuccess: @escaping () async -> Void) async {
    switch await repository.brand
      .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
    {
    case .success:
      showToast.toggle()
      await onSuccess()
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to edit brand': \(error.localizedDescription)")
    }
  }

  func uploadLogo() async {
    guard let data = await selectedLogo?.getJPEG() else { return }
    switch await repository.brand.uploadLogo(brandId: brand.id, data: data) {
    case .success:
      await onUpdate()
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("uplodaing company logo failed: \(error.localizedDescription)")
    }
  }
}
