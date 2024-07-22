import Models
import Repositories
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

extension EditSuggestion {
    var open: Router.Open {
        switch self {
        case let .product(editSuggestion):
            .sheet(.productAdmin(id: editSuggestion.product.id))
        case let .brand(editSuggestion):
            .sheet(.brandAdmin(id: editSuggestion.brand.id))
        case let .subBrand(editSuggestion):
            .sheet(.brandAdmin(id: editSuggestion.subBrand.brand.id))
        case let .company(editSuggestion):
            .sheet(.companyAdmin(id: editSuggestion.company.id))
        }
    }
}
