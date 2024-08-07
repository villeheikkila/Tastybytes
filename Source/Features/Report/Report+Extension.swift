import Components

import Models
import SwiftUI

public extension Report.Content {
    var navigationTitle: LocalizedStringKey {
        switch self {
        case .product:
            "report.navigationTitle.product"
        case .company:
            "report.navigationTitle.company"
        case .brand:
            "report.navigationTitle.brand"
        case .subBrand:
            "report.navigationTitle.subBrand"
        case .checkIn:
            "report.navigationTitle.checkIn"
        case .comment:
            "report.navigationTitle.comment"
        case .checkInImage:
            "report.navigationTitle.checkInImage"
        case .profile:
            "report.navigationTitle.profile"
        case .location:
            "report.navigationTitle.location"
        }
    }
}

extension Report.Content {
    var open: Router.Open {
        switch self {
        case let .brand(brand):
            .screen(.brand(brand.id))
        case let .product(product):
            .screen(.product(product.id))
        case let .company(company):
            .screen(.company(company.id))
        case let .subBrand(subBrand):
            .screen(.subBrand(brandId: subBrand.brand.id, subBrandId: subBrand.id))
        case let .checkIn(checkIn):
            .screen(.checkIn(checkIn.id))
        case let .comment(comment):
            .screen(.checkIn(comment.checkIn.id))
        case let .checkInImage(imageEntity):
            .screen(.checkIn(imageEntity.checkInId))
        case let .profile(profile):
            .screen(.profile(profile))
        case let .location(location):
            .screen(.location(location.id))
        }
    }
}

extension Report.Joined {
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
            .sheet(.checkInAdmin(id: checkIn.id, open: .report(id)))
        case let .comment(comment):
            .sheet(.checkInCommentAdmin(id: comment.id, open: .report(id)))
        case let .checkInImage(imageEntity):
            .sheet(.checkInImageAdmin(id: imageEntity.id, open: .report(id)))
        case let .profile(profile):
            .sheet(.profileAdmin(id: profile.id, open: .report(id)))
        case let .location(location):
            .sheet(.locationAdmin(id: location.id, open: .report(id)))
        }
    }
}
