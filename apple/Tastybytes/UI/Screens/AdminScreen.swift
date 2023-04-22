import SwiftUI

struct AdminScreen: View {
  var body: some View {
    List {
      RouterLink("Categories", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .categoryManagement)
      RouterLink("Flavors", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .flavorManagement)
      RouterLink("Verification", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .verification)
      RouterLink("Duplicates", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .duplicateProducts)
    }
    .navigationBarTitle("Admin")
    .navigationBarTitleDisplayMode(.inline)
  }
}
