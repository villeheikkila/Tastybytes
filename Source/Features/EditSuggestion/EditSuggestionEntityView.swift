import Models
import SwiftUI

struct EditSuggestionEntityView: View {
    let editSuggestion: EditSuggestion

    var body: some View {
        switch editSuggestion {
        case let .brand(editSuggestion):
            BrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .product(editSuggestion):
            ProductEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .company(editSuggestion):
            CompanyEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .subBrand(editSuggestion):
            SubBrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        }
    }
}
