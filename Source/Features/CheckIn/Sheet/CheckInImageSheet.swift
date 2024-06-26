import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInImageSheet: View {
    typealias OnDeleteImageCallback = (_ imageEntity: ImageEntity) async -> Void

    private let logger = Logger(category: "CheckInImageSheet")
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentImage: ImageEntity
    @State private var showDeleteConfirmationFor: ImageEntity?
    let checkIn: CheckIn

    let onDeleteImage: OnDeleteImageCallback?

    init(checkIn: CheckIn, onDeleteImage: OnDeleteImageCallback?) {
        self.checkIn = checkIn
        currentImage = if let firstImage = checkIn.images.first {
            firstImage
        } else {
            .init(id: 0, file: "", bucket: "", blurHash: nil)
        }
        self.onDeleteImage = onDeleteImage
    }

    var body: some View {
        TabView(selection: $currentImage) {
            ForEach(checkIn.images) { image in
                VStack(alignment: .center) {
                    if let imageUrl = image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                        ZoomableRemoteImage(imageUrl: imageUrl, blurHash: image.blurHash)
                    }
                }
                .tag(image)
            }
        }
        .tabViewStyle(.page)
        .safeAreaInset(edge: .bottom, content: {
            CheckInImageCheckInSection(checkIn: checkIn)
        })
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if let imageUrl = currentImage.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                ImageShareLink(url: imageUrl, title: "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))")
            }
            Menu {
                if let imageUrl = currentImage.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                    SaveToPhotoGalleryButton(imageUrl: imageUrl)
                }
                ReportButton(entity: .checkInImage(.init(checkIn: checkIn, imageEntity: currentImage)))
                if profileEnvironmentModel.profile.id == checkIn.profile.id {
                    Button("labels.delete", systemImage: "trash", role: .destructive, action: { showDeleteConfirmationFor = currentImage })
                }

            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
            .confirmationDialog(
                "checkInImage.deleteConfirmation.title",
                isPresented: $showDeleteConfirmationFor.isNotNull(),
                titleVisibility: .visible,
                presenting: showDeleteConfirmationFor
            ) { presenting in
                ProgressButton(
                    "checkIn.image.deleteConfirmation.label",
                    role: .destructive,
                    action: { await deleteImage(presenting) }
                )
            }
        }
        ToolbarDismissAction()
    }

    func deleteImage(_ imageEntity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .checkInImages, entity: imageEntity) {
        case .success:
            await onDeleteImage?(imageEntity)
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CheckInImageCheckInSection: View {
    let checkIn: CheckIn

    var body: some View {
        VStack {
            CheckInCardHeader(
                profile: checkIn.profile,
                loadedFrom: .checkIn,
                location: checkIn.location
            )
            CheckInCardProduct(
                product: checkIn.product,
                loadedFrom: .checkIn,
                productVariant: checkIn.variant,
                servingStyle: checkIn.servingStyle
            )
        }
        .allowsHitTesting(false)
        .padding()
        .background(.ultraThinMaterial)
    }
}
