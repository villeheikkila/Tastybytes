import SFSafeSymbols
import SwiftUI

struct CameraView: View {
    @State private var cameraModel: CameraModel
    @Binding private var isPresented: Bool

    init(onCapture: @escaping (_ image: UIImage) -> Void, isPresented: Binding<Bool>) {
        _cameraModel = State(wrappedValue: CameraModel(onCapture: onCapture))
        _isPresented = isPresented
    }

    var body: some View {
        GeometryReader { geometry in
            GeometryReader { imageGeometry in
                if let image = cameraModels.viewfinderImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageGeometry.size.width, height: imageGeometry.size.height)
                }
            }
            .overlay(alignment: .bottom) {
                cameraControls
                    .frame(height: geometry.size.height * 0.15)
                    .background(.ultraThinMaterial)
            }
            .overlay(alignment: .center) {
                Color.clear
                    .frame(height: geometry.size.height * (1 - 0.15))
                    .accessibilityElement()
                    .accessibilityLabel("View Finder")
                    .accessibilityAddTraits([.isImage])
            }
            .background(.black)
            .ignoresSafeArea()
        }
        .task {
            await cameraModels.camera.start()
        }
    }

    private var cameraControls: some View {
        HStack(spacing: 60) {
            Spacer()
            CameraControlButton(title: "Close Camera", systemSymbol: .xmark, action: { isPresented = false })
            TakePhotoButton(title: "Take Photo", action: { cameraModels.camera.takePhoto() })
            CameraControlButton(
                title: "Switch Camera",
                systemSymbol: .arrowTriangle2Circlepath,
                action: { cameraModels.camera.switchCaptureDevice() }
            )
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
}

private struct TakePhotoButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 62, height: 62)
                    Circle()
                        .fill(.white)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

private struct CameraControlButton: View {
    let title: LocalizedStringKey
    let systemSymbol: SFSymbol
    let action: () -> Void

    var body: some View {
        Button(title, systemSymbol: systemSymbol, action: action)
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(.white)
    }
}
