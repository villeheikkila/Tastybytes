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
      if viewModel.initialValuesLoaded {
        ProgressView()
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
      } else {
        colorSchemeSection
        notificationSection
      }
    }
    .navigationTitle("Application")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.setInitialValues(systemColorScheme: systemColorScheme, profile: profileManager.get())
    }
  }

  private var colorSchemeSection: some View {
    Section {
      Toggle("Use System Color Scheme", isOn: .init(get: {
        viewModel.isSystemColor
      }, set: { newValue in
        viewModel.isSystemColor = newValue
        Task { await viewModel.updateColorScheme { await profileManager.refresh() } }
      }))
      Toggle("Use Dark Mode", isOn: .init(get: {
        viewModel.isDarkMode
      }, set: { newValue in
        viewModel.isDarkMode = newValue
        Task { await viewModel.updateColorScheme { await profileManager.refresh() } }
      }))
      .disabled(viewModel.isSystemColor)
    } header: {
      Text("Color Scheme")
    }
  }

  private var notificationSection: some View {
    Section {
      Toggle("Reactions", isOn: .init(get: {
        viewModel.reactionNotifications
      }, set: { newValue in
        viewModel.reactionNotifications = newValue
        Task { await viewModel.updateNotificationSettings() }
      }))
      Toggle("Friend Requests", isOn: .init(get: {
        viewModel.friendRequestNotifications
      }, set: { newValue in
        viewModel.friendRequestNotifications = newValue
        Task { await viewModel.updateNotificationSettings() }
      }))
      Toggle("Check-in Tags", isOn: .init(get: {
        viewModel.checkInTagNotifications
      }, set: { newValue in
        viewModel.checkInTagNotifications = newValue
        Task { await viewModel.updateNotificationSettings() }
      }))
    } header: {
      Text("Notifications")
    }
  }
}
