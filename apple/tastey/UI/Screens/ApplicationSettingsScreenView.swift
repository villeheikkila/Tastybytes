import SwiftUI

struct ApplicationSettingsScreenView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var currentProfile: CurrentProfile
    @Environment(\.colorScheme) var systemColorScheme

    var body: some View {
        Form {
            Section {
                Toggle("Use System Color Scheme", isOn: $viewModel.isSystemColor).onChange(of: [self.viewModel.isSystemColor].publisher.first()) { _ in
                    viewModel.updateColorScheme({ currentProfile.refresh() })
                }
                Toggle("Use Dark Mode", isOn: $viewModel.isDarkMode).onChange(of: [self.viewModel.isDarkMode].publisher.first()) { _ in
                    viewModel.updateColorScheme({ currentProfile.refresh() })
                }.disabled(viewModel.isSystemColor)
            }
        }
        .navigationTitle("Application")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.setInitialValues(systemColorScheme: systemColorScheme, userColorScheme: currentProfile.profile?.colorScheme)
        }
    }
}

extension ApplicationSettingsScreenView {
    enum Toast {
        case profileUpdated
        case exported
        case exportError
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var isSystemColor = false
        @Published var isDarkMode = false
        var initialColorScheme: ColorScheme?

        func setInitialValues(systemColorScheme: ColorScheme, userColorScheme: Profile.ColorScheme?) {
            initialColorScheme = systemColorScheme
            switch userColorScheme {
            case .light:
                isDarkMode = false
                isSystemColor = false
            case .dark:
                isDarkMode = true
                isSystemColor = false
            case .system:
                isDarkMode = initialColorScheme == ColorScheme.dark
                isSystemColor = true
            default:
                isDarkMode = initialColorScheme == ColorScheme.dark
            }
        }

        func updateColorScheme(_ onChange: @escaping () -> Void) {
            if isSystemColor {
                isDarkMode = initialColorScheme == ColorScheme.dark
            }
            let update = Profile.Update(
                isDarkMode: isDarkMode, isSystemColor: isSystemColor
            )

            Task {
                _ = try await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                        update: update)
                onChange()
            }
        }
    }
}
