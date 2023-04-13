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
      Toggle("Use System Color Scheme", isOn: $viewModel.isSystemColor)
        .onChange(of: [viewModel.isSystemColor].publisher.first()) { _ in
          Task { await viewModel.updateColorScheme { await profileManager.refresh() } }
        }
      Toggle("Use Dark Mode", isOn: $viewModel.isDarkMode)
        .onChange(of: [viewModel.isDarkMode].publisher.first()) { _ in
          Task { await viewModel.updateColorScheme { await profileManager.refresh() } }
        }
        .disabled(viewModel.isSystemColor)
    } header: {
      Text("Color Scheme")
    }
  }

  private var notificationSection: some View {
    Section {
      Toggle("Reactions", isOn: $viewModel.reactionNotifications)
        .onChange(of: [viewModel.reactionNotifications].publisher.first()) { _ in
          Task { await viewModel.updateNotificationSettings() }
        }
      Toggle("Friend Requests", isOn: $viewModel.friendRequestNotifications)
        .onChange(of: [viewModel.friendRequestNotifications].publisher.first()) { _ in
          Task { await viewModel.updateNotificationSettings() }
        }
      Toggle("Check-in Tags", isOn: $viewModel.checkInTagNotifications)
        .onChange(of: [viewModel.checkInTagNotifications].publisher.first()) { _ in
          Task { await viewModel.updateNotificationSettings() }
        }
    } header: {
      Text("Notifications")
    }
  }
}
