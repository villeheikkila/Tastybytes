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
            ControllableImage(imageUrl: imageUrl, blurHash: checkIn.images.first?.blurHash)
        }
        .safeAreaInset(edge: .bottom, content: {
            CheckInImageCheckInSection(checkIn: checkIn)
        })
        .toolbarBackground(.visible, for: .navigationBar)
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
                        Button("Delete", systemImage: "trash", role: .destructive, action: { showDeleteConfirmationFor = imageEntity })
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
struct SaveToPhotoGalleryButton: View {
    let imageUrl: URL

    var body: some View {
        ProgressButton("Add to photo gallery", systemImage: "arrow.down.circle", action: downloadImage)
    }

    func downloadImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            guard let image = UIImage(data: data) else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } catch {
            return
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
            CheckInCardCheckIn(checkIn: checkIn, loadedFrom: .checkIn)
        }
        .allowsHitTesting(false)
        .padding()
        .background(.ultraThinMaterial)
    }
}

@MainActor
struct ControllableImage: View {
    @State private var scale: CGFloat = 1.0
    @State private var location: CGPoint?
    let imageUrl: URL
    let blurHash: BlurHash?

    private let minScaleFactor = 0.8

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale != 1.0 else { return }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    location = value.location
                }
            }
    }

    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scaleFactor in
                guard scaleFactor > minScaleFactor else { return }
                scale = scaleFactor.magnitude
            }
    }

    var body: some View {
        GeometryReader { geometry in
            RemoteImage(url: imageUrl) { state in
                let height = geometry.size.height * 0.8
                let width = geometry.size.width * 0.8
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(8)
                        .scaleEffect(scale)
                        .position(location ?? .init(x: geometry.size.width / 2, y: geometry.size.height / 2))
                        .simultaneousGesture(zoomGesture)
                        .simultaneousGesture(dragGesture)
                        .frame(width: width, height: height)
                        .onTapGesture(count: 2) {
                            scale = 1
                            location = .init(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                } else if let blurHash {
                    BlurHashPlaceholder(blurHash: blurHash, height: height, width: width)
                } else {
                    ProgressView()
                }
            }
        }
    }
}
