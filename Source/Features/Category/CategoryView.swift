import Components
import Models
import SwiftUI

struct CategoryView: View {
    let category: CategoryProtocol

    var body: some View {
        CategoryNameView(category: category, withBorder: false)
    }
}
