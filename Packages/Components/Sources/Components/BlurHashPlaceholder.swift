import Extensions
import Models
import SwiftUI

public struct BlurHashPlaceholder: View {
    let blurHash: CheckIn.BlurHash?
    let height: Double
    @State private var image: UIImage?
    @State private var task: Task<Void, Never>?

    public init(blurHash: CheckIn.BlurHash? = nil, height: Double) {
        self.blurHash = blurHash
        self.height = height
    }

    public var body: some View {
        HStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
                    .accessibility(hidden: true)
            } else {
                ProgressView()
            }
        }
        .onDisappear {
            task?.cancel()
        }
        .task {
            guard let blurHash else { return }
            task = Task {
                await withTaskGroup(of: UIImage?.self) { group in
                    group.addTask(priority: .background) {
                        await withCheckedContinuation { continuation in
                            DispatchQueue.global().async {
                                let decodedImage = UIImage(
                                    blurHash: blurHash.hash,
                                    size: CGSize(width: 50, height: 50)
                                )
                                continuation.resume(returning: decodedImage)
                            }
                        }
                    }
                    for await decodedImage in group {
                        image = decodedImage
                    }
                }
            }
        }
    }
}
