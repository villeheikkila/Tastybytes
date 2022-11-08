import AlertToast
import SwiftUI

class ToastController: ObservableObject {
    @Published var show = false
    @Published var alertToast = AlertToast(type: .regular, title: "SOME TITLE") {
        didSet {
            show.toggle()
        }
    }
}

struct WithToast<Content: View>: View {
    @StateObject var toastController = ToastController()

    let content: () -> Content

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(toastController)
            .toast(isPresenting: $toastController.show) {
                toastController.alertToast
            }
    }
}
