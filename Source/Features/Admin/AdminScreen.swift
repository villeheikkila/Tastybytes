import EnvironmentModels
import SwiftUI

struct AdminScreen: View {
    var body: some View {
        List {
            RouterLink("admin.category.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .categoryManagement)
            RouterLink("admin.flavor.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .flavorManagement)
            RouterLink("admin.verification.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .verification)
            RouterLink("admin.duplicates.title", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .duplicateProducts)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Admin")
    }
}
