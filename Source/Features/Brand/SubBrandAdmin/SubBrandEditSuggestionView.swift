import Models
import SwiftUI

struct SubBrandEditSuggestionView: View {
    let editSuggestion: SubBrand.EditSuggestion

    var body: some View {
        VStack {
            if let name = editSuggestion.name {
                Text(name)
            }
        }
    }
}
