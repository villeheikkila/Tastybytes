import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct AdminTab: View {
    var body: some View {
        AdminScreen()
            .backToRootOnTab(.admin)
    }
}

