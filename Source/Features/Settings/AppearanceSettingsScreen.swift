import SwiftUI

struct AppearanceSettingsScreen: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage(.colorScheme) private var colorScheme = CustomColorScheme.system.rawValue

    var scheme: CustomColorScheme {
        CustomColorScheme(rawValue: colorScheme) ?? .system
    }

    var body: some View {
        Form {
            Toggle("Use System Color Scheme", isOn: .init(get: {
                scheme == .system
            }, set: { newValue in
                if newValue {
                    colorScheme = CustomColorScheme.system.rawValue
                } else {
                    colorScheme = systemColorScheme == .dark ? CustomColorScheme.dark.rawValue : CustomColorScheme.light
                        .rawValue
                }
            }))
            Toggle("Use Dark Mode", isOn: .init(get: {
                scheme == .system ? systemColorScheme == .dark : scheme == .dark
            }, set: { newValue in
                colorScheme = newValue ? CustomColorScheme.dark.rawValue : CustomColorScheme.light.rawValue
            }))
            .disabled(colorScheme == "system")
        }
        .navigationTitle("settings.appearance.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
