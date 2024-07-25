import Models

extension Profile.Contributions: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .profiles,
                [
                    buildQuery(name: "products", foreignKey: "products!products_created_by_fkey", [Product.getQuery(.joinedBrandSubcategories(false))]),
                    buildQuery(name: "companies", foreignKey: "companies!companies_created_by_fkey", [Company.getQuery(.saved(false))]),
                    buildQuery(name: "brands", foreignKey: "brands!brands_created_by_fkey", [Brand.getQuery(.saved(false))]),
                    buildQuery(name: "sub_brands", foreignKey: "sub_brands!sub_brands_created_by_fkey", [SubBrand.getQuery(.joinedBrand(false))]),
                    buildQuery(name: "barcodes", foreignKey: "product_barcodes!product_barcodes_created_by_fkey", [Product.Barcode.getQuery(.joined(false))]),
                    buildQuery(name: "reports", foreignKey: "reports!reports_created_by_fkey", [Report.getQuery(.joined(false))]),
                    Product.EditSuggestion.getQuery(.joined(true)),
                    Company.EditSuggestion.getQuery(.joined(true)),
                    Brand.EditSuggestion.getQuery(.joined(true)),
                    SubBrand.EditSuggestion.getQuery(.joined(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
