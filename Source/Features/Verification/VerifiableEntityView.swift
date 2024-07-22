import Models
import SwiftUI

struct VerifiableEntityView: View {
    let entity: VerifiableEntity

    var body: some View {
        Section {
            switch entity {
            case let .product(product):
                RouterLink(open: .sheet(.productAdmin(id: product.id))) {
                    ProductEntityView(product: product)
                }
            case let .brand(brand):
                RouterLink(open: .sheet(.brandAdmin(id: brand.id))) {
                    BrandEntityView(brand: brand)
                }
            case let .subBrand(subBrand):
                RouterLink(open: .sheet(.brandAdmin(id: subBrand.brand.id))) {
                    SubBrandEntityView(subBrand: subBrand)
                }
            case let .company(company):
                RouterLink(open: .sheet(.companyAdmin(id: company.id))) {
                    CompanyEntityView(company: company)
                }
            }
        }
    }
}
