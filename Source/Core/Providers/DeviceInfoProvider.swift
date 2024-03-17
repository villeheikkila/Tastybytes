import SwiftUI
import TipKit

@MainActor
struct DeviceInfoProvider<Content: View>: View {
    @AppStorage(.colorScheme) var colorScheme: String = "system"
    @State private var isPortrait = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .preferredColorScheme(CustomColorScheme(rawValue: colorScheme)?.systemColorScheme)
        #if !os(watchOS)
            .detectOrientation($isPortrait)
            .environment(\.isPortrait, isPortrait)
        #endif
            .task {
                try? Tips.configure([.displayFrequency(.daily)])
            }
    }
}
