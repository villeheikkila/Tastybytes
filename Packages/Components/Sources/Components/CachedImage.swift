import Models
import SwiftUI
internal import Cache

public struct CachedImageView<Content: View>: View {
    public init(image: any ImageEntityProtocol, imageLoader: @escaping CachedImageView<Content>.ImageLoader, content: @escaping CachedImageView<Content>.ImageBuilder) {
        self.image = image
        self.imageLoader = imageLoader
        self.content = content
    }

    public typealias ImageBuilder = (SwiftUI.Image) -> Content
    public typealias ImageLoader = (ImageEntityProtocol) async throws -> Data

    let image: ImageEntityProtocol
    let imageLoader: ImageLoader
    let content: ImageBuilder

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    public var body: some View {
        VStack {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else if isLoading {
                if let blurHash = image.blurHash {
                    BlurHashPlaceholderView(blurHash: blurHash)
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
        guard let storage = try? Storage<String, UIImage>(
            diskConfig: .init(name: "Disk"),
            memoryConfig: .init(expiry: .seconds(86400)),
            transformer: TransformerFactory.forImage()
        ) else { return }
        isLoading = true
        do {
            let storedImage = try? await storage.async.object(forKey: image.cacheKey)
            if let storedImage {
                uiImage = storedImage
                isLoading = false
                return
            }
            let data = try await imageLoader(image)
            if let loadedImage = UIImage(data: data) {
                uiImage = loadedImage
                try await storage.async.setObject(loadedImage, forKey: image.cacheKey)
            }
        } catch {
            guard !error.isCancelled else { return }
        }
        isLoading = false
    }
}
