import Extensions
import SwiftUI

@MainActor
public extension View {
    func fullScreenImageCrop(isPresented: Binding<Bool>, image: UIImage?,
                             onSubmit: @escaping (_ image: UIImage?) -> Void) -> some View
    {
        fullScreenCover(isPresented: isPresented, content: {
            NavigationStack {
                CropView(crop: .square, image: image, onSubmit: onSubmit)
            }
        })
    }
}

@MainActor
struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @State private var selectedCropType: Crop = .rectangle
    @GestureState private var isInteracting = false

    private let coordinateSpace = "cropView"

    let crop: Crop
    let image: UIImage?
    let onSubmit: (_ image: UIImage?) -> Void

    var body: some View {
        imageView()
            .navigationTitle("crop.navigationTitle")
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

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { renderFinalImage() }, label: {
                Label("labels.done", systemImage: "checkmark")
                    .labelStyle(.iconOnly)
                    .font(.callout)
                    .fontWeight(.semibold)
            })
        }

        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                onSubmit(image)
                dismiss()
            }, label: {
                Label("labels.close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .font(.callout)
                    .fontWeight(.semibold)
            })
        }
    }

    @ViewBuilder
    func imageView() -> some View {
        let cropSize = crop.size()
        GeometryReader { geometry in
            let size = geometry.size
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .accessibilityLabel("crop.resize.accessibilityLabel")
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

    func renderFinalImage() {
        let renderer = ImageRenderer(content: imageView())
        renderer.proposedSize = .init(crop.size())
        if let image = renderer.uiImage {
            onSubmit(image)
        } else {
            onSubmit(image)
        }
        dismiss()
    }
}

enum Crop: Equatable {
    case rectangle
    case square
    case custom(CGSize)

    func name() -> LocalizedStringKey {
        switch self {
        case .rectangle:
            "crop.rectangle"
        case .square:
            "crop.square"
        case let .custom(cGSize):
            "crop.custom \(Int(cGSize.width))X\(Int(cGSize.height))"
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
