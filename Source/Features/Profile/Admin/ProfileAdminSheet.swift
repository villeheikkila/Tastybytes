import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfileAdminSheet: View {
    let profile: Profile

    var body: some View {
        Form {}
            .navigationTitle("profile.admin.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarDismissAction()
            }
    }
}
