import Extensions
import SwiftUI

public extension View {
    func fullScreenImageCrop(isPresented: Binding<Bool>, image: UIImage?,
                             finalImage: Binding<UIImage?>) -> some View
    {
        fullScreenCover(isPresented: isPresented, content: {
            NavigationStack {
                CropView(finalImage: finalImage, crop: .square, image: image)
            }
        })
    }
}

struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @State private var selectedCropType: Crop = .rectangle
    @GestureState private var isInteracting: Bool = false
    @Binding var finalImage: UIImage?

    private let coordinateSpace = "cropView"

    var crop: Crop
    var image: UIImage?

    var body: some View {
        ImageView()
            .navigationTitle("Crop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.black.ignoresSafeArea()
            }
            .toolbar {
                toolbarContent
            }
    }

    @MainActor
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { renderFinalImage() }) {
                Image(systemName: "checkmark")
                    .font(.callout)
                    .fontWeight(.semibold)
            }
        }

        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                finalImage = image
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.callout)
                    .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    func ImageView() -> some View {
        let cropSize = crop.size()
        GeometryReader { geometry in
            let size = geometry.size
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .named(coordinateSpace))
                            Color.clear
                                .onChange(of: isInteracting) { _, newValue in
                                    if !newValue {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if rect.minX > 0 {
                                                offset.width = (offset.width - rect.minX)
                                            }
                                            if rect.minY > 0 {
                                                offset.height = (offset.height - rect.minY)
                                            }

                                            if rect.maxX < size.width {
                                                offset.width = (rect.minX - offset.width)
                                            }

                                            if rect.maxY < size.height {
                                                offset.height = (rect.minY - offset.height)
                                            }
                                        }
                                        lastStoredOffset = offset
                                    }
                                }
                        }
                    }
                    .frame(size)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .coordinateSpace(name: coordinateSpace)
        .gesture(
            DragGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                })
                .onChanged { value in
                    let translation = value.translation
                    offset = CGSize(
                        width: translation.width + lastStoredOffset.width,
                        height: translation.height + lastStoredOffset.height
                    )
                }
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                })
                .onChanged { value in
                    let updatedScale = value + lastScale
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            lastScale = scale - 1
                        }
                    }
                }
        )
        .frame(cropSize)
    }

    @MainActor
    func renderFinalImage() {
        let renderer = ImageRenderer(content: ImageView())
        renderer.proposedSize = .init(crop.size())
        if let image = renderer.uiImage {
            finalImage = image
        } else {
            finalImage = image
        }
        dismiss()
    }
}

enum Crop: Equatable {
    case rectangle
    case square
    case custom(CGSize)

    func name() -> String {
        switch self {
        case .rectangle:
            "Rectangle"
        case .square:
            "Square"
        case let .custom(cGSize):
            "Custom \(Int(cGSize.width))X\(Int(cGSize.height))"
        }
    }

    func size() -> CGSize {
        switch self {
        case .rectangle:
            .init(width: 300, height: 500)
        case .square:
            .init(width: 300, height: 300)
        case let .custom(cGSize):
            cGSize
        }
    }
}
