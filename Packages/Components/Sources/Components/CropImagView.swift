import SwiftUI

struct CropImagView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @Binding var croppedImage: UIImage?

    let image: UIImage

    init(
        image: UIImage,
        croppedImage: Binding<UIImage?>
    ) {
        self.image = image
        _croppedImage = croppedImage
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                imageView
                    .gesture(MagnificationGesture().onChanged { value in
                        scale = value.magnitude
                    }
                    .onEnded { value in
                        scale = value.magnitude
                        if scale < 1 {
                            withAnimation {
                                scale = 1
                                offset = .zero
                                newPosition = .zero
                            }
                        }
                    })
                    .simultaneousGesture(DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: value.translation.width + newPosition.width,
                                height: value.translation.height + newPosition.height
                            )
                        }
                        .onEnded { value in
                            offset = CGSize(
                                width: value.translation.width + newPosition.width,
                                height: value.translation.height + newPosition.height
                            )
                            newPosition = offset

                            repositionImageIfNeeded(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                        })
                viewFinder
            }
            .frame(maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .overlay(alignment: .bottom) {
                AddImageButton {
                    cropImage(width: geometry.size.width, height: geometry.size.width)
                }
            }
        }
    }

    var imageView: some View {
        Rectangle()
            .fill(.clear)
            .aspectRatio(1, contentMode: .fit)
            .border(Color.red, width: 1)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
            }
    }

    var viewFinder: some View {
        Rectangle()
            .fill(Color.black.opacity(0.6))
            .mask {
                ZStack {
                    Rectangle()
                    Rectangle()
                        .aspectRatio(1, contentMode: .fit)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            }
            .overlay {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(1, contentMode: .fit)
                    .border(Color.white, width: 1)
            }
            .allowsHitTesting(false)
    }

    @MainActor func cropImage(width: Double, height: Double) {
        let clippedImage = imageView.frame(width: width, height: height).clipped()
        guard let image = ImageRenderer(content: clippedImage).uiImage else { return }
        croppedImage = image
        dismiss()
    }

    func repositionImageIfNeeded(width: CGFloat, height: CGFloat) {
        guard let cgImage = image.cgImage else { return }

        let imageWidth = width * scale
        let imageHeight = (CGFloat(cgImage.height) / (CGFloat(cgImage.width) / width)) * scale

        let remainingX = (imageWidth - width) / 2
        let remainingY = (imageHeight - height) / 2
        let imageOffsetX = offset.width
        let imageOffsetY = offset.height

        if abs(imageOffsetX) > remainingX {
            withAnimation {
                offset.width = imageOffsetX.sign == .minus ? -abs(remainingX) : abs(remainingX)
                newPosition.width = offset.width
            }
        }

        if abs(imageOffsetY) > remainingY {
            withAnimation {
                offset.height = imageOffsetY.sign == .minus ? -abs(remainingY) : abs(remainingY)
                newPosition.height = offset.height
            }
        }
    }
}

public extension View {
    func fullScreenImageCrop(isPresented: Binding<Bool>, image: UIImage?,
                             croppedImage: Binding<UIImage?>) -> some View
    {
        fullScreenCover(isPresented: isPresented, content: {
            if let image {
                CropImagView(image: image, croppedImage: croppedImage)
                    .background(.black)
            } else {
                EmptyView()
            }
        })
    }
}

struct AddImageButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Add Image")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.blue)
                }
        }
        .padding()
    }
}
