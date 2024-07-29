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

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        CachedImageView(image: image, imageLoader: repository.imageEntity.getData, content: content)
    }
}
