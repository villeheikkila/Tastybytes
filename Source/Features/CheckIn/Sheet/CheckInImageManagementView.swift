import Components

import Models
import Logging
import PhotosUI
import Repositories
import SwiftUI

struct CheckInImageManagementView: View {
    private let logger = Logger(label: "CheckInImageManagementView")

    @Environment(AppModel.self) private var appModel
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router

    @State private var showPhotoPicker = false
    @State private var photoSelection: PhotosPickerItem?
    @State private var showPhotoMenu = false
    @State private var showCamera = false

    @Binding var newImages: [UIImage]
    @Binding var images: [ImageEntity.Saved]
    @Binding var checkInAt: Date
    @Binding var locationFromImage: Location.Saved?

    var totalImages: Int {
        images.count + newImages.count
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 3) {
                ForEach(images) { image in
                    ImageEntityView(image: image, content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cardStyle()
                            .frame(height: 150)
                            .padding(.leading, 2)
                            .accessibilityLabel("checkIn.image.label")
                    })
                    .overlayDeleteButton(action: {
                        await deleteImage(image)
                    })
                }
                ForEach(newImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cardStyle()
                        .frame(height: 150)
                        .accessibilityLabel("checkIn.image.label")
                        .overlayDeleteButton(action: {
                            if let index = newImages.firstIndex(of: image) {
                                _ = withAnimation {
                                    newImages.remove(at: index)
                                }
                            }

                        })
                }
                AddPhotoButtonView {
                    showPhotoMenu.toggle()
                }
                .opacity(totalImages >= 2 ? 0 : 1)
                .confirmationDialog("checkIn.photo.title", isPresented: $showPhotoMenu) {
                    RouterLink("checkIn.photo.picker.camera", open: .fullScreenCover(.cameraWithCropping(onSubmit: { image in
                        guard let image else { return }
                        newImages.append(image)
                    })))
                    Button(
                        "checkIn.photo.picker.photoGallery",
                        action: {
                            showPhotoPicker = true
                        }
                    )
                } message: {
                    Text("checkIn.photo.picker.title")
                }
                Spacer()
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoSelection, matching: .images, photoLibrary: .shared())
        .task(id: photoSelection) {
            defer { photoSelection = nil }
            guard let photoSelection, let data = await photoSelection.getImageData() else { return }
            if let imageTakenAt = photoSelection.imageMetadata.date {
                checkInAt = imageTakenAt
            }
            if let imageTakenLocation = photoSelection.imageMetadata.location {
                await getLocationFromCoordinate(coordinate: imageTakenLocation)
            }
            guard let image = UIImage(data: data) else { return }
            router.open(.fullScreenCover(.cropImage(image: image, onSubmit: { image in
                guard let image else { return }
                newImages.append(image)
            })))
        }
        .scrollIndicators(.hidden)
    }

    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D) async {
        guard let countryCode = try? await coordinate.getISOCountryCode() else { return }
        let country = appModel.countries.first(where: { $0.countryCode == .init(rawValue: countryCode) })
        locationFromImage = .init(coordinate: coordinate, countryCode: countryCode, country: country)
    }

    private func deleteImage(_ entity: ImageEntity.Saved) async {
        do {
            try await repository.imageEntity.delete(from: .checkInImages, id: entity.id)
            withAnimation {
                images.remove(object: entity)
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct AddPhotoButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center) {
                Spacer()
                Label("checkIn.image.add", systemImage: "camera")
                    .font(.system(size: 24))
                Spacer()
            }
            .labelStyle(.iconOnly)
            .frame(width: 110, height: 150)
            .cardStyle()
        }
    }
}
