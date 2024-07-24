import Components
import Models
import SwiftUI

struct CategoryEntityView: View {
    let category: CategoryProtocol

    var body: some View {
        CategoryNameView(category: category, withBorder: false)
    }
}
