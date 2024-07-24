import Components
import Models
import SwiftUI

struct SubCategoryEntityView: View {
    let subcategory: SubcategoryProtocol

    var body: some View {
        Text(subcategory.name)
    }
}
