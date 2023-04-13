import SwiftUI

struct ApplicationSettingsScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.colorScheme) private var systemColorScheme

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
      await viewModel.setInitialValues(systemColorScheme: systemColorScheme, profile: profileManager.get())
    }
  }

  private var colorSchemeSection: some View {
    Section {
      Group {
        Toggle("Use System Color Scheme", isOn: $viewModel.isSystemColor)
        Toggle("Use Dark Mode", isOn: $viewModel.isDarkMode)
          .disabled(viewModel.isSystemColor)
      }
      .asyncOnChange(of: [viewModel.isDarkMode].publisher.first()) { _ in
        await viewModel.updateColorScheme { await profileManager.refresh() }
      }
    } header: {
      Text("Color Scheme")
    }
  }

  private var notificationSection: some View {
    Section {
      Group {
        Toggle("Reactions", isOn: $viewModel.reactionNotifications)
        Toggle("Friend Requests", isOn: $viewModel.friendRequestNotifications)
        Toggle("Check-in Tags", isOn: $viewModel.checkInTagNotifications)
      }
      .asyncOnChange(of: [viewModel.checkInTagNotifications].publisher.first()) { _ in
        await viewModel.updateNotificationSettings()
      }
    } header: {
      Text("Notifications")
    }
  }
}
