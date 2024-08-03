import Components
import Models
import SwiftUI

struct SubcategoryView: View {
    let subcategory: SubcategoryProtocol

    var body: some View {
        Text(subcategory.name)
    }
}
