import Components
import Extensions
import Models
import Repositories
import SwiftUI

struct SaveToPhotoGalleryButtonView: View {
    @Environment(Repository.self) private var repository
    let image: ImageEntity.Saved

    var body: some View {
        AsyncButton("saveToPhotoGalleryButton.label", systemImage: "arrow.down.circle", action: downloadImage)
    }

    private func downloadImage() async {
        do {
            let data = try await repository.imageEntity.getData(entity: image)
            guard let image = UIImage(data: data) else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } catch {
            return
        }
    }
}
