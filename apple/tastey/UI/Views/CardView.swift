import SwiftUI

struct CardView<Content: View>: View {
    var content: () -> Content

    var body: some View {
        HStack {
            VStack {
                content()
                    .padding(.all, 10)
            }
            .background(Color(.tertiarySystemBackground).opacity(0.4))
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
        }
        .clipped()
        .cornerRadius(10)
        .padding(.all, 10)
    }
}
