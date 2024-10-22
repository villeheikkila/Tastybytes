import Components
import Models
import Logging
import Repositories
import SwiftUI

struct CheckInImageSheet: View {
    typealias OnDeleteImageCallback = (_ id: ImageEntity.Id) async -> Void

    private let logger = Logger(label: "CheckInImageSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentImage: ImageEntity.Saved
    @State private var showDeleteConfirmationFor: ImageEntity.Saved?
    let checkIn: CheckIn.Joined
    @State private var images: [ImageEntity.Saved]

    let onDeleteImage: OnDeleteImageCallback?

    init(checkIn: CheckIn.Joined, onDeleteImage: OnDeleteImageCallback?) {
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
            tabs
        }
        .tabViewStyle(.page)
        .safeAreaInset(edge: .bottom, content: {
            CheckInImageCheckInSectionView(checkIn: checkIn)
        })
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var tabs: some View {
        ForEach(images) { image in
            ZoomableRemoteImageView(imageEntity: image)
                .tag(image)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ImageShareLinkView(
                image: currentImage,
                title: "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))"
            )
            Menu {
                SaveToPhotoGalleryButtonView(image: currentImage)
                if profileModel.profile.id == checkIn.profile.id {
                    Button("labels.delete", systemImage: "trash", role: .destructive, action: {
                        showDeleteConfirmationFor = currentImage
                    })
                }
                Divider()
                ReportButton(entity: .checkInImage(.init(checkIn: checkIn, imageEntity: currentImage)))
                Divider()
                AdminRouterLink(open: .sheet(.checkInImageAdmin(id: currentImage.id, onDelete: { id in
                    withAnimation {
                        images = images.removingWithId(id)
                    }
                    await onDeleteImage?(id)
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

    private func deleteImage(_ imageEntity: ImageEntity.Saved) async {
        do {
            try await repository.imageEntity.delete(from: .checkInImages, id: imageEntity.id)
            withAnimation {
                images = images.removing(imageEntity)
            }
            await onDeleteImage?(imageEntity.id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CheckInImageCheckInSectionView: View {
    let checkIn: CheckIn.Joined

    var body: some View {
        VStack {
            CheckInHeaderView(
                profile: checkIn.profile,
                location: checkIn.location
            )
            ProductView(product: checkIn.product, variant: checkIn.variant)
                .productLogoLocation(.right)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
