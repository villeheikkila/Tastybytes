import SwiftUI

struct PreferencesScreenView: View {
  @StateObject private var viewModel = ViewModel()

  var body: some View {
    List {
      Section {
        NavigationLink(destination: ProfileSettingsScreenView()) {
          Label("Profile", systemImage: "person.crop.circle")
        }

        NavigationLink(destination: AccountSettingsScreenView()) {
          Label("Account", systemImage: "gear")
        }

        NavigationLink(destination: ApplicationSettingsScreenView()) {
          Label("Application", systemImage: "gear")
        }

        NavigationLink(destination: AppIconScreenView()) {
          Label("App Icon", systemImage: "app.fill")
        }

        NavigationLink(destination: BlockedUsersScreenView()) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }
      }

      Section {
        NavigationLink(destination: AboutScreenView()) {
          Label("About", systemImage: "info.circle")
        }
      }

      Section {
        Button(action: { viewModel.logOut() }) {
          Label("Log Out", systemImage: "arrow.uturn.left")
            .fontWeight(.medium)
        }
      }
    }
    .navigationBarTitle("Preferences")
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension PreferencesScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "PreferencesScreenView")
    func logOut() {
      Task {
        await repository.auth.logOut()
      }
    }
  }
}
