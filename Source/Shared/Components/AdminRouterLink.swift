import EnvironmentModels
import SwiftUI

struct AdminRouterLink: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    let open: Router.Open

    var body: some View {
        if profileEnvironmentModel.hasRole(.admin) {
            RouterLink("labels.admin", systemImage: "wrench.and.screwdriver", open: open)
        }
    }
}
