import SwiftUI

struct TermsOfServiceScreen: View {
    var body: some View {
        TermsOfServiceView()
            .navigationTitle("termsOfService.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceSheet: View {
    var body: some View {
        TermsOfServiceView()
            .webViewTranslucentBackground(true)
            .navigationTitle("termsOfService.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarDismissAction()
            }
    }
}
