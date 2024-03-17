import Components
import SwiftUI

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
