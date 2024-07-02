import EnvironmentModels
import SwiftUI

struct AdminScreen: View {
    var body: some View {
        List {
            RouterLink("admin.category.title", systemImage: "rectangle.stack", screen: .categoryManagement)
            RouterLink("flavor.navigationTitle", systemImage: "face.smiling", screen: .flavorManagement)
            RouterLink("admin.verification.title", systemImage: "checkmark.seal", screen: .verification)
            RouterLink("admin.duplicates.title", systemImage: "plus.square.on.square", screen: .duplicateProducts)
            RouterLink("report.admin.navigationTitle", systemImage: "exclamationmark.bubble", screen: .reports)
            RouterLink("admin.locations.title", systemImage: "mappin.square", screen: .locationManagement)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("admin.navigationTitle")
    }
}
