import Models
import Swift
import SwiftUI

struct AdminEventContentView: View {
    let content: AdminEvent.Content

    var body: some View {
        switch content {
        case let .company(company):
            CompanyView(company: company)
        case let .product(product):
            ProductView(product: product)
        case let .subBrand(subBrand):
            SubBrandView(subBrand: subBrand)
        case let .brand(brand):
            BrandView(brand: brand)
        case let .profile(profile):
            ProfileView(profile: profile)
        case let .editSuggestion(editSuggestion):
            EditSuggestionView(editSuggestion: editSuggestion)
        case let .report(report):
            ReportContentView(content: report.content)
        }
    }
}
