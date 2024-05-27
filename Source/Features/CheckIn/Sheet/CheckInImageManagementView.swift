import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CheckInImageManagementView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Binding var newImages: [UIImage]
    @Binding var images: [ImageEntity]
    @Binding var showPhotoMenu: Bool
    @Binding var showCamera: Bool
    @Binding var showPhotoPicker: Bool

    let deleteImage: (_ image: ImageEntity) async -> Void

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
                    Button("checkIn.photo.picker.camera", action: { showCamera.toggle() })
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
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 16)
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
