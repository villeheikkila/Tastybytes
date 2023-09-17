import Models
import Supabase

struct SupabaseProductBarcodeRepository: ProductBarcodeRepository {
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
