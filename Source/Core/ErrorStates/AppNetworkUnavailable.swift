import SwiftUI
import Components

struct AppNetworkUnavailable: View {
    var body: some View {
        ContentUnavailableView(label: {
            VStack {
                Image(systemName: "wifi.slash")
                    .imageScale(.large)
                    .accessibilityHidden(true)
                Text("App can't connect to the internet")
                    .font(.callout)
            }
        }, description: {
        }, actions: {
            ProgressButton("Try again", action: {})
        })
    }
}

#Preview {
    AppNetworkUnavailable()
}
