import Components
import Extensions
import SwiftUI

struct SaveToPhotoGalleryButtonView: View {
    let imageUrl: URL

    var body: some View {
        AsyncButton("saveToPhotoGalleryButton.label", systemImage: "arrow.down.circle", action: downloadImage)
    }

    private func downloadImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl, delegate: nil)
            guard let image = UIImage(data: data) else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } catch {
            return
        }
    }
}
