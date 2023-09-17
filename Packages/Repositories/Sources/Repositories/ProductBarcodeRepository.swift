import Models
import Supabase

public protocol ProductBarcodeRepository {
    func getByProductId(id: Int) async -> Result<[ProductBarcode.JoinedWithCreator], Error>
    func addToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

public struct SupabaseProductBarcodeRepository: ProductBarcodeRepository {
    let client: SupabaseClient

    public func getByProductId(id: Int) async -> Result<[ProductBarcode.JoinedWithCreator], Error> {
        do {
            let response: [ProductBarcode.JoinedWithCreator] = try await client
                .database
                .from(.productBarcodes)
                .select(columns: ProductBarcode.getQuery(.joinedCreator(false)))
                .eq(column: "product_id", value: id)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func addToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error> {
        do {
            try await client
                .database
                .from(.productBarcodes)
                .insert(
                    values: ProductBarcode.NewRequest(product: product, barcode: barcode),
                    returning: .representation
                )
                .execute()

            return .success(barcode)
        } catch {
            return .failure(error)
        }
    }

    public func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.productBarcodes)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

extension ProductBarcode {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.productBarcodes.rawValue
        let saved = "id, barcode, type"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        case let .joinedCreator(withTableName):
            return queryWithTableName(
                tableName,
                [saved, "created_at", Profile.getQuery(.minimal(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedCreator(_ withTableName: Bool)
    }
}
