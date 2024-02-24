import EnvironmentModels
import SwiftUI

@MainActor
struct AdminScreen: View {
    var body: some View {
        List {
            RouterLink("admin.category.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .categoryManagement)
            RouterLink("flavor.navigationTitle", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .flavorManagement)
            RouterLink("admin.verification.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .verification)
            RouterLink("admin.duplicates.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .duplicateProducts)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("admin.navigationTitle")
    }
}
