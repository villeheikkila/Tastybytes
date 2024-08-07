import Models
import Repositories
import SwiftUI

struct EditSuggestionView: View {
    let editSuggestion: EditSuggestion

    var body: some View {
        VStack(alignment: .leading) {
            CreationInfoHeaderView(
                createdBy: editSuggestion.createdBy,
                createdAt: editSuggestion.createdAt,
                resolvedAt: editSuggestion.resolvedAt
            )
            EditSuggestionContentView(editSuggestion: editSuggestion)
        }
    }
}

struct EditSuggestionContentView: View {
    let editSuggestion: EditSuggestion

    var body: some View {
        switch editSuggestion {
        case let .brand(editSuggestion):
            BrandEditSuggestionView(editSuggestion: editSuggestion)
        case let .product(editSuggestion):
            ProductEditSuggestionView(editSuggestion: editSuggestion)
        case let .company(editSuggestion):
            CompanyEditSuggestionView(editSuggestion: editSuggestion)
        case let .subBrand(editSuggestion):
            SubBrandEditSuggestionView(editSuggestion: editSuggestion)
        }
    }
}

extension EditSuggestion {
    var open: Router.Open {
        switch self {
        case let .product(editSuggestion):
            .sheet(.productAdmin(id: editSuggestion.product.id, open: .editSuggestions(editSuggestion.id)))
        case let .brand(editSuggestion):
            .sheet(.brandAdmin(id: editSuggestion.brand.id, open: .editSuggestions(editSuggestion.id)))
        case let .subBrand(editSuggestion):
            .sheet(.subBrandAdmin(id: editSuggestion.subBrand.id, open: .editSuggestions(editSuggestion.id)))
        case let .company(editSuggestion):
            .sheet(.companyAdmin(id: editSuggestion.company.id, open: .editSuggestions(editSuggestion.id)))
        }
    }
}
