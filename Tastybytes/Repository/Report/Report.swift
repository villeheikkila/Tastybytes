struct Report: Codable, Identifiable {
    let id: Int
    let message: String

    struct NewRequest: Codable, Sendable {
        let message: String
        let checkInId: Int?
        let productId: Int?
        let companyId: Int?
        let checkInCommentId: Int?
        let brandId: Int?
        let subBrandId: Int?

        init(message: String, entity: Entity) {
            self.message = message

            switch entity {
            case let .product(product):
                productId = product.id
                checkInId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
            case let .company(company):
                companyId = company.id
                checkInId = nil
                productId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
            case let .brand(brand):
                brandId = brand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                subBrandId = nil
            case let .subBrand(_, subBrand):
                subBrandId = subBrand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
            case let .comment(comment):
                checkInCommentId = comment.id
                checkInId = nil
                productId = nil
                companyId = nil
                brandId = nil
                subBrandId = nil
            case let .checkIn(checkIn):
                checkInId = checkIn.id
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
            }
        }

        enum CodingKeys: String, CodingKey {
            case message
            case checkInId = "check_in_id"
            case productId = "product_id"
            case companyId = "company_id"
            case checkInCommentId = "check_in_comment_id"
            case brandId = "brand_id"
            case subBrandId = "sub_brand_id"
        }
    }

    enum Entity: Hashable {
        case product(Product.Joined)
        case company(Company)
        case brand(Brand.JoinedSubBrandsProductsCompany)
        case subBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct)
        case checkIn(CheckIn)
        case comment(CheckInComment)

        var label: String {
            switch self {
            case .product:
                return "product"
            case .company:
                return "company"
            case .brand:
                return "brand"
            case .subBrand:
                return "sub-brand"
            case .checkIn:
                return "check-in"
            case .comment:
                return "comment"
            }
        }
    }
}

extension Report {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "reports"
        let saved = "id, message"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
