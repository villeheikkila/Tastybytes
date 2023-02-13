import SwiftUI

struct ApplicationSettingsScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.colorScheme) var systemColorScheme

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    Form {
      colorSchemeSection
      notificationSection
    }
    .navigationTitle("Application")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      viewModel.setInitialValues(systemColorScheme: systemColorScheme, profile: profileManager.get())
    }
  }

  private var colorSchemeSection: some View {
    Section {
      Toggle("Use System Color Scheme", isOn: $viewModel.isSystemColor)
        .onChange(of: [self.viewModel.isSystemColor].publisher.first()) { _ in
          viewModel.updateColorScheme { profileManager.refresh() }
        }
      Toggle("Use Dark Mode", isOn: $viewModel.isDarkMode)
        .onChange(of: [self.viewModel.isDarkMode].publisher.first()) { _ in
          viewModel.updateColorScheme { profileManager.refresh() }
        }
        .disabled(viewModel.isSystemColor)
    } header: {
      Text("Color Scheme")
    }
  }

  private var notificationSection: some View {
    Section {
      Toggle("Reactions", isOn: $viewModel.reactionNotifications)
        .onChange(of: [self.viewModel.reactionNotifications].publisher.first()) { _ in
          viewModel.updateNotificationSettings()
        }
      Toggle("Friend Requests", isOn: $viewModel.friendRequestNotifications)
        .onChange(of: [self.viewModel.friendRequestNotifications].publisher.first()) { _ in
          viewModel.updateNotificationSettings()
        }
      Toggle("Check-in Tags", isOn: $viewModel.checkInTagNotifications)
        .onChange(of: [self.viewModel.checkInTagNotifications].publisher.first()) { _ in
          viewModel.updateNotificationSettings()
        }
    } header: {
      Text("Notifications")
    }
  }
}
