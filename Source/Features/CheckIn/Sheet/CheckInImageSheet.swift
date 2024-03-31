import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInImageSheet: View {
    typealias OnDeleteImageCallback = (_ imageEntity: ImageEntity) -> Void

    private let logger = Logger(category: "CheckInImageSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmationFor: ImageEntity?
    let checkIn: CheckIn
    let imageUrl: URL

    let onDeleteImage: OnDeleteImageCallback?

    var body: some View {
        VStack(alignment: .center) {
            ZoomableRemoteImage(imageUrl: imageUrl, blurHash: checkIn.images.first?.blurHash)
        }
        .safeAreaInset(edge: .bottom, content: {
            CheckInImageCheckInSection(checkIn: checkIn)
        })
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ImageShareLink(url: imageUrl, title: "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))")
            Menu {
                SaveToPhotoGalleryButton(imageUrl: imageUrl)
                if let imageEntity = checkIn.images.first {
                    ReportButton(entity: .checkInImage(.init(checkIn: checkIn, imageEntity: imageEntity)))
                    if profileEnvironmentModel.profile.id == checkIn.profile.id {
                        Button("labels.delete", systemImage: "trash", role: .destructive, action: { showDeleteConfirmationFor = imageEntity })
                    }
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
            withAnimation {
                onDeleteImage?(imageEntity)
                dismiss()
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
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
