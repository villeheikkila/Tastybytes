import Foundation
public import Tagged

public extension Product {
    struct Detailed: Identifiable, Hashable, Decodable, Sendable, ModificationInfo, ProductProtocol {
        public let id: Product.Id
        public let name: String?
        public let description: String?
        public let isVerified: Bool
        public let subBrand: SubBrand.JoinedBrand
        public let category: Category.Saved
        public let subcategories: [Subcategory.Saved]
        public let barcodes: [Product.Barcode.JoinedWithCreator]
        public let editSuggestions: [EditSuggestion]
        public let variants: [Product.Variant.JoinedCompany]
        public let reports: [Report.Joined]
        public let isDiscontinued: Bool
        public let logos: [Logo.Saved]
        public let createdBy: Profile.Saved?
        public let createdAt: Date
        public let updatedBy: Profile.Saved?
        public let updatedAt: Date?

        enum CodingKeys: String, CodingKey, Sendable {
            case id
            case name
            case description
            case isVerified = "is_verified"
            case subBrand = "sub_brands"
            case category = "categories"
            case subcategories
            case barcodes = "product_barcodes"
            case editSuggestions = "product_edit_suggestions"
            case variants = "product_variants"
            case reports
            case isDiscontinued = "is_discontinued"
            case logos
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        init(
            id: Product.Id,
            name: String? = nil,
            description: String? = nil,
            isVerified: Bool,
            subBrand: SubBrand.JoinedBrand,
            category: Category.Saved,
            subcategories: [Subcategory.Saved],
            barcodes: [Product.Barcode.JoinedWithCreator],
            editSuggestions: [Product.EditSuggestion],
            variants: [Product.Variant.JoinedCompany],
            reports: [Report.Joined],
            isDiscontinued: Bool,
            logos: [Logo.Saved],
            createdBy: Profile.Saved? = nil,
            createdAt: Date,
            updatedBy: Profile.Saved? = nil,
            updatedAt: Date? = nil
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.isVerified = isVerified
            self.subBrand = subBrand
            self.category = category
            self.subcategories = subcategories
            self.barcodes = barcodes
            self.editSuggestions = editSuggestions
            self.variants = variants
            self.reports = reports
            self.isDiscontinued = isDiscontinued
            self.logos = logos
            self.createdBy = createdBy
            self.createdAt = createdAt
            self.updatedBy = updatedBy
            self.updatedAt = updatedAt
        }

        public init() {
            id = .init(rawValue: 0)
            name = nil
            description = nil
            isVerified = false
            subBrand = .init()
            category = .init()
            subcategories = []
            barcodes = []
            editSuggestions = []
            variants = []
            reports = []
            isDiscontinued = false
            logos = []
            createdBy = nil
            createdAt = Date.now
            updatedBy = nil
            updatedAt = nil
        }

        public func mergeWith(product: Product.Joined) -> Product.Detailed {
            .init(
                id: id,
                name: product.name,
                description: product.description,
                isVerified: isVerified,
                subBrand: product.subBrand,
                category: product.category,
                subcategories: product.subcategories,
                barcodes: barcodes,
                editSuggestions: editSuggestions,
                variants: variants,
                reports: reports,
                isDiscontinued: product.isDiscontinued,
                logos: logos,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }

        public func copyWith(
            name: String? = nil,
            description: String? = nil,
            isVerified: Bool? = nil,
            subBrand: SubBrand.JoinedBrand? = nil,
            category: Category.Saved? = nil,
            subcategories: [Subcategory.Saved]? = nil,
            barcodes: [Product.Barcode.JoinedWithCreator]? = nil,
            editSuggestions: [Product.EditSuggestion]? = nil,
            variants: [Product.Variant.JoinedCompany]? = nil,
            reports: [Report.Joined]? = nil,
            isDiscontinued: Bool? = nil,
            logos: [Logo.Saved]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                description: description ?? self.description,
                isVerified: isVerified ?? self.isVerified,
                subBrand: subBrand ?? self.subBrand,
                category: category ?? self.category,
                subcategories: subcategories ?? self.subcategories,
                barcodes: barcodes ?? self.barcodes,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                variants: variants ?? self.variants,
                reports: reports ?? self.reports,
                isDiscontinued: isDiscontinued ?? self.isDiscontinued,
                logos: logos ?? self.logos,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }
    }
}
