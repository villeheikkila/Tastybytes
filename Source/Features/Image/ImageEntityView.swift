import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct ImageEntityView<Content: View>: View {
    let logger = Logger(category: "ImageEntityView")
    public typealias ImageBuilder = (Image) -> Content

    @Environment(Repository.self) private var repository
    let image: ImageEntityProtocol
    let content: ImageBuilder

    @State private var loadedImage: Image?
    @State private var isLoading = false

    var body: some View {
        VStack {
            if let loadedImage {
                content(loadedImage)
            } else if isLoading {
                if let blurHash = image.blurHash {
                    BlurHashPlaceholderView(blurHash: blurHash.hash)
                } else {
                    ProgressView()
                }
            } else {
                Color.clear
            }
        }
        .task {
            await loadImage(image: image)
        }
    }

    private func loadImage(image: ImageEntityProtocol) async {
        isLoading = true
        do {
            let data = try await repository.imageEntity.getData(entity: image)
            loadedImage = await convertDataToUIImage(data: data)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load image file \(image.file) from bucket \(image.bucket). Error \(error)")
        }
        isLoading = false
    }

    private nonisolated func convertDataToUIImage(data: Data) async -> Image? {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
        } else {
            nil
        }
    }
}
