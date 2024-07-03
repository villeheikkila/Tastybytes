import Models
internal import Supabase

struct SupabaseProductBarcodeRepository: ProductBarcodeRepository {
    let client: SupabaseClient

    func getByProductId(id: Int) async -> Result<[ProductBarcode.JoinedWithCreator], Error> {
        do {
            let response: [ProductBarcode.JoinedWithCreator] = try await client
                .from(.productBarcodes)
                .select(ProductBarcode.getQuery(.joinedCreator(false)))
                .eq("product_id", value: id)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func addToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error> {
        do {
            try await client
                .from(.productBarcodes)
                .insert(ProductBarcode.NewRequest(product: product, barcode: barcode),
                        returning: .representation)
                .execute()

            return .success(barcode)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .from(.productBarcodes)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
