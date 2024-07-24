public extension Profile {
    struct Contributions: Decodable, Sendable {
        public let products: [Product.Joined]
        public let companies: [Company.Saved]
        public let brands: [Brand.Saved]
        public let subBrands: [SubBrand.JoinedBrand]
        public let barcodes: [Product.Barcode.Joined]
        public let reports: [Report.Joined]
        public let editSuggestions: [EditSuggestion]

        enum CodingKeys: String, CodingKey {
            case products
            case companies
            case brands
            case subBrands = "sub_brands"
            case barcodes
            case reports
            case productEditSuggestions = "product_edit_suggestions"
            case companyEditSuggestions = "company_edit_suggestions"
            case brandEditSuggestions = "brand_edit_suggestions"
            case subBrandEditSuggestions = "sub_brand_edit_suggestions"
        }

        public init(
            products: [Product.Joined],
            companies: [Company.Saved],
            brands: [Brand.Saved],
            subBrands: [SubBrand.JoinedBrand],
            barcodes: [Product.Barcode.Joined],
            reports: [Report.Joined],
            editSuggestions: [EditSuggestion]
        ) {
            self.products = products
            self.companies = companies
            self.brands = brands
            self.subBrands = subBrands
            self.barcodes = barcodes
            self.reports = reports
            self.editSuggestions = editSuggestions
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            products = try container.decode([Product.Joined].self, forKey: .products)
            companies = try container.decode([Company.Saved].self, forKey: .companies)
            brands = try container.decode([Brand.Saved].self, forKey: .brands)
            subBrands = try container.decode([SubBrand.JoinedBrand].self, forKey: .subBrands)
            barcodes = try container.decode([Product.Barcode.Joined].self, forKey: .barcodes)
            reports = try container.decode([Report.Joined].self, forKey: .reports)
            let productEditSuggestions: [EditSuggestion] = try container.decode([Product.EditSuggestion].self, forKey: .productEditSuggestions).map { .product($0) }
            let companyEditSuggestions: [EditSuggestion] = try container.decode([Company.EditSuggestion].self, forKey: .companyEditSuggestions).map { .company($0) }
            let brandEditSuggestions: [EditSuggestion] = try container.decode([Brand.EditSuggestion].self, forKey: .brandEditSuggestions).map { .brand($0) }
            let subBrandEditSuggestions: [EditSuggestion] = try container.decode([SubBrand.EditSuggestion].self, forKey: .subBrandEditSuggestions).map { .subBrand($0) }
            let editSuggestions = productEditSuggestions + companyEditSuggestions + brandEditSuggestions + subBrandEditSuggestions
            self.editSuggestions = editSuggestions.sorted(by: { $0.createdAt > $1.createdAt })
        }

        public func copyWith(
            products: [Product.Joined]? = nil,
            companies: [Company.Saved]? = nil,
            brands: [Brand.Saved]? = nil,
            subBrands: [SubBrand.JoinedBrand]? = nil,
            barcodes: [Product.Barcode.Joined]? = nil,
            reports: [Report.Joined]? = nil,
            editSuggestions: [EditSuggestion]? = nil
        ) -> Self {
            .init(
                products: products ?? self.products,
                companies: companies ?? self.companies,
                brands: brands ?? self.brands,
                subBrands: subBrands ?? self.subBrands,
                barcodes: barcodes ?? self.barcodes,
                reports: reports ?? self.reports,
                editSuggestions: editSuggestions ?? self.editSuggestions
            )
        }
    }
}
