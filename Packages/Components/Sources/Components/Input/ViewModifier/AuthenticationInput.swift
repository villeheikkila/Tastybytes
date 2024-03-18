import SwiftUI

struct AuthenticationInput: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .padding(5)
        #if !os(watchOS)
            .background(Color(.systemGray6))
        #endif
            .cornerRadius(12)
            .padding(.vertical, 5)
    }
}
