import EnvironmentModels
import Models
import SwiftUI

struct NotificationTab: View {
    @Environment(Router.self) private var router

    var body: some View {
        NotificationScreen()
    }
}
