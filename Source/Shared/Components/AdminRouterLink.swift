
import SwiftUI

struct AdminRouterLink: View {
    @Environment(ProfileModel.self) private var profileModel

    let open: Router.Open

    var body: some View {
        if profileModel.hasRole(.admin) {
            RouterLink("labels.admin", systemImage: "wrench.and.screwdriver", open: open)
        }
    }
}
