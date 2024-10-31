import SwiftUI

extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap(\.windows)
            .first {
                $0.isKeyWindow
            }
    }
}

private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension EnvironmentValues {
    @MainActor
    @Entry
    var safeAreaInsets = UIApplication.shared.currentWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
}
