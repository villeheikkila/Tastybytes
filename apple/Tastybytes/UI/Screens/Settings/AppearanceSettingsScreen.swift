import SwiftUI

struct AppearanceSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.colorScheme) private var systemColorScheme

  var body: some View {
    Form {
      Toggle("Use System Color Scheme", isOn: .init(get: {
        profileManager.isSystemColor
      }, set: { newValue in
        profileManager.isSystemColor = newValue
        Task { await profileManager.updateColorScheme() }
      }))
      Toggle("Use Dark Mode", isOn: .init(get: {
        profileManager.isSystemColor ? systemColorScheme == .dark : profileManager.isDarkMode
      }, set: { newValue in
        profileManager.isDarkMode = newValue
        Task { await profileManager.updateColorScheme() }
      }))
      .disabled(profileManager.isSystemColor)
    }
    .navigationTitle("Appearance")
    .navigationBarTitleDisplayMode(.inline)
  }
}
