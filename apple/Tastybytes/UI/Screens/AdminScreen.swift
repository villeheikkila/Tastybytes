import SwiftUI

struct AdminScreen: View {
  var body: some View {
    List {
      RouterLink("Categories", systemSymbol: .plusRectangleFillOnRectangleFill, screen: .categoryManagement)
      RouterLink("Flavors", systemSymbol: .plusRectangleFillOnRectangleFill, screen: .flavorManagement)
      RouterLink("Verification", systemSymbol: .plusRectangleFillOnRectangleFill, screen: .verification)
      RouterLink("Duplicates", systemSymbol: .plusRectangleFillOnRectangleFill, screen: .duplicateProducts)
    }
    .listStyle(.insetGrouped)
    .navigationBarTitle("Admin")
  }
}
