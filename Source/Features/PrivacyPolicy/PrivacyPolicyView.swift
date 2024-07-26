
import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        WebView(url: appModel.config.privacyPolicyUrl)
    }
}
