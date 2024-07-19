import Models
import Repositories
import SwiftUI

struct ReportEntityView: View {
    let entity: Report.Entity

    var body: some View {
        switch entity {
        case let .product(product):
            ProductEntityView(product: product, extras: [.companyLink, .logoOnRight])
        case let .company(company):
            CompanyEntityView(company: company)
        case let .brand(brand):
            BrandEntityView(brand: brand)
        case let .subBrand(subBrand):
            SubBrandEntityView(brand: subBrand.brand, subBrand: subBrand)
        case let .comment(comment):
            CheckInCommentEntityView(comment: comment)
        case let .checkIn(checkIn):
            CheckInEntityView(checkIn: checkIn)
        case let .checkInImage(imageEntity):
            CheckInImageEntityView(imageEntity: imageEntity)
        case let .profile(profile):
            ProfileEntityView(profile: profile)
        case let .location(location):
            LocationEntityView(location: location)
        }
    }
}

extension Report.Entity {
    var open: Router.Open {
        switch self {
        case let .brand(brand):
            .screen(.brand(brand))
        case let .product(product):
            .screen(.product(product))
        case let .company(company):
            .screen(.company(company))
        case let .subBrand(subBrand):
            .navigatablePath(.brand(id: subBrand.brand.id))
        case let .checkIn(checkIn):
            .screen(.checkIn(checkIn))
        case let .comment(comment):
            .navigatablePath(.company(id: comment.id))
        case let .checkInImage(imageEntity):
            .navigatablePath(.checkIn(id: imageEntity.checkIn.id))
        case let .profile(profile):
            .screen(.profile(profile))
        case let .location(location):
            .screen(.location(location))
        }
    }
}
