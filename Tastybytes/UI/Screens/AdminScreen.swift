import EnvironmentModels
import SwiftUI

struct AdminScreen: View {
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel

    var body: some View {
        List {
            RouterLink("Categories", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .categoryManagement)
            RouterLink("Flavors", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .flavorManagement)
            RouterLink("Verification", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .verification)
            RouterLink("Duplicates", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .duplicateProducts)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Admin")
        .dismissSplashScreen()
    }
}
