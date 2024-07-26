import SwiftUI

struct PrivacyPolicyScreen: View {
    var body: some View {
        PrivacyPolicyView()
            .navigationTitle("privacyPolicy.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicySheet: View {
    var body: some View {
        PrivacyPolicyView()
            .webViewTranslucentBackground(true)
            .navigationTitle("privacyPolicy.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarDismissAction()
            }
    }
}
