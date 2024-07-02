import Components
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CheckInImageManagementView: View {
    private let logger = Logger(category: "CheckInImageManagementView")

    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router

    @State private var showPhotoPicker = false
    @State private var photoSelection: PhotosPickerItem?
    @State private var showPhotoMenu = false
    @State private var showCamera = false

    @Binding var newImages: [UIImage]
    @Binding var images: [ImageEntity]
    @Binding var checkInAt: Date
    @Binding var locationFromImage: Location?

    var totalImages: Int {
        images.count + newImages.count
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 3) {
                ForEach(images) { image in
                    RemoteImage(url: image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: 8))
                                .frame(height: 150)
                                .shadow(radius: 1)
                                .accessibilityLabel("checkIn.image.label")
                        }
                    }
                    .overlayDeleteButton(action: {
                        await deleteImage(image)
                    })
                }
                ForEach(newImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 8))
                        .frame(height: 150)
                        .shadow(radius: 1)
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
        .contentMargins(.horizontal, 16)
    }

    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D) async {
        let countryCode = try? await coordinate.getISOCountryCode()
        let country = appEnvironmentModel.countries.first(where: { $0.countryCode == countryCode })
        locationFromImage = Location(coordinate: coordinate, countryCode: countryCode, country: country)
    }

    func deleteImage(_ entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .checkInImages, entity: entity) {
        case .success:
            withAnimation {
                images.remove(object: entity)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct AddPhotoButtonView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Label("checkIn.image.add", systemImage: "camera")
                .font(.system(size: 24))
            Spacer()
        }
        .labelStyle(.iconOnly)
        .frame(width: 110, height: 150)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .shadow(radius: 1)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            action()
        }
        .padding(.vertical, 1)
    }
}
