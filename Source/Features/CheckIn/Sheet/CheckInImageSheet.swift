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
    @State private var images: [ImageEntity]

    let onDeleteImage: OnDeleteImageCallback?

    init(checkIn: CheckIn, onDeleteImage: OnDeleteImageCallback?) {
        self.checkIn = checkIn
        _images = State(initialValue: checkIn.images)
        currentImage = if let firstImage = checkIn.images.first {
            firstImage
        } else {
            .init(id: 0, file: "", bucket: "", blurHash: nil, createdAt: Date.now)
        }
        self.onDeleteImage = onDeleteImage
    }

    var body: some View {
        TabView(selection: $currentImage) {
            ForEach(images) { image in
                VStack(alignment: .center) {
                    if let imageUrl = image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                        ZoomableRemoteImageView(imageUrl: imageUrl, blurHash: image.blurHash)
                    }
                }
                .tag(image)
            }
        }
        .tabViewStyle(.page)
        .safeAreaInset(edge: .bottom, content: {
            CheckInImageCheckInSectionView(checkIn: checkIn)
        })
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if let imageUrl = currentImage.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                ImageShareLinkView(url: imageUrl, title: "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))")
            }
            Menu {
                if let imageUrl = currentImage.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                    SaveToPhotoGalleryButtonView(imageUrl: imageUrl)
                }
                if profileEnvironmentModel.profile.id == checkIn.profile.id {
                    Button("labels.delete", systemImage: "trash", role: .destructive, action: { showDeleteConfirmationFor = currentImage })
                }
                Divider()
                ReportButton(entity: .checkInImage(.init(checkIn: checkIn, imageEntity: currentImage)))
                Divider()
                AdminRouterLink(open: .sheet(.checkInImageAdmin(checkIn: checkIn, imageEntity: currentImage, onDelete: { imageEntity in
                    withAnimation {
                        images = images.removing(imageEntity)
                    }
                    await onDeleteImage?(imageEntity)
                })))
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
                AsyncButton(
                    "checkIn.image.deleteConfirmation.label",
                    role: .destructive,
                    action: { await deleteImage(presenting) }
                )
            }
        }
        ToolbarDismissAction()
    }

    private func deleteImage(_ imageEntity: ImageEntity) async {
        do {
            try await repository.imageEntity.delete(from: .checkInImages, entity: imageEntity)
            withAnimation {
                images = images.removing(imageEntity)
            }
            await onDeleteImage?(imageEntity)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CheckInImageCheckInSectionView: View {
    let checkIn: CheckIn

    var body: some View {
        VStack {
            CheckInCardHeader(
                profile: checkIn.profile,
                location: checkIn.location
            )
            CheckInCardProduct(
                product: checkIn.product,
                productVariant: checkIn.variant,
                servingStyle: checkIn.servingStyle
            )
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
