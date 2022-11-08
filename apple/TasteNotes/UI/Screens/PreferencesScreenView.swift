import SwiftUI

struct PreferencesScreenView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        List {
            NavigationLink(destination: ProfileSettingsScreenView()) {
                Text("Profile")
            }
            
            NavigationLink(destination: ApplicationSettingsScreenView()) {
                Text("Application")
            }
            
            NavigationLink(destination: BlockedUsersScreenView()) {
                Text("Blocked Users")
            }
            
            NavigationLink(destination: DeleteAccountScreenView()) {
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

extension PreferencesScreenView {
    @MainActor class ViewModel: ObservableObject {
        func logOut() {
            Task {
                try await repository.auth.logOut()
            }
        }
    }
}
