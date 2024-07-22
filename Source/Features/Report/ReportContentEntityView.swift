import Models
import Repositories
import SwiftUI

struct ReportContentEntityView: View {
    let content: Report.Content

    var body: some View {
        switch content {
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

extension Report.Content {
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
            .navigatablePath(.checkIn(id: comment.checkIn.id))
        case let .checkInImage(imageEntity):
            .navigatablePath(.checkIn(id: imageEntity.checkIn.id))
        case let .profile(profile):
            .screen(.profile(profile))
        case let .location(location):
            .screen(.location(location))
        }
    }
}

extension Report {
    var open: Router.Open {
        switch content {
        case let .brand(brand):
            .sheet(.brandAdmin(id: brand.id, open: .report(id)))
        case let .product(product):
            .sheet(.productAdmin(id: product.id, open: .report(id)))
        case let .company(company):
            .sheet(.companyAdmin(id: company.id, open: .report(id)))
        case let .subBrand(subBrand):
            .sheet(.subBrandAdmin(id: subBrand.id, open: .report(id)))
        case let .checkIn(checkIn):
            .sheet(.checkInAdmin(id: checkIn.id))
        case let .comment(comment):
            .sheet(.checkInCommentAdmin(id: comment.id))
        case let .checkInImage(imageEntity):
            .navigatablePath(.checkIn(id: imageEntity.checkIn.id))
        case let .profile(profile):
            .sheet(.profileAdmin(id: profile.id))
        case let .location(location):
            .sheet(.locationAdmin(id: location.id))
        }
    }
}
