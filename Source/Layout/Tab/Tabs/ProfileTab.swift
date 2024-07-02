import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfileTab: View {
    @Environment(Router.self) private var router

    var body: some View {
        CurrentProfileScreen()
    }
}
