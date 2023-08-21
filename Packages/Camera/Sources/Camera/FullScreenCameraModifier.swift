import SwiftUI

public extension View {
    func fullScreenCamera(isPresented: Binding<Bool>, onCapture: @escaping (UIImage) -> Void) -> some View {
        fullScreenCover(isPresented: isPresented, content: {
            NavigationStack {
                CameraView(onCapture: onCapture, isPresented: isPresented)
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        })
    }
}
