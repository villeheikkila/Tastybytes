import SwiftUI

struct AuthenticationInput: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .padding(5)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.vertical, 5)
    }
}
