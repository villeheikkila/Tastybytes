import SwiftUI

struct PreferencesMenuView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        List {
            NavigationLink(destination: ProfileSettingsView()) {
                Text("Profile")
            }
            
            NavigationLink(destination: ApplicationSettingsView()) {
                Text("Application")
            }
            
            NavigationLink(destination: BlockedUsersView()) {
                Text("Blocked Users")
            }
            
            NavigationLink(destination: DeleteAccountView()) {
                Text("Delete Account")
            }

            Section{
                Button("Log Out", action: { viewModel.logOut() }).fontWeight(.bold)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension PreferencesMenuView {
    @MainActor class ViewModel: ObservableObject {
        func logOut() {
            Task {
                try await repository.auth.logOut()
            }
        }
    }
}
