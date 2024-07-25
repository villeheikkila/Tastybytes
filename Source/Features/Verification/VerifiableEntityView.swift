import Models
import SwiftUI

struct VerifiableEntityView: View {
    let entity: VerifiableEntity

    var body: some View {
        Section {
            RouterLink(open: entity.open) {
                switch entity {
                case let .product(product):
                    ProductEntityView(product: product)
                case let .brand(brand):
                    BrandEntityView(brand: brand)
                case let .subBrand(subBrand):
                    SubBrandEntityView(subBrand: subBrand)
                case let .company(company):
                    CompanyEntityView(company: company)
                }
            }
        }
    }
}

extension VerifiableEntity {
    var open: Router.Open {
        switch self {
        case let .product(product):
            .sheet(.productAdmin(id: product.id))
        case let .brand(brand):
            .sheet(.brandAdmin(id: brand.id))
        case let .subBrand(subBrand):
            .sheet(.brandAdmin(id: subBrand.brand.id))
        case let .company(company):
            .sheet(.companyAdmin(id: company.id))
        }
    }
}
