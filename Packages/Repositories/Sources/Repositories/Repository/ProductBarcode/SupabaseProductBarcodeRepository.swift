import Models
internal import Supabase

struct SupabaseProductBarcodeRepository: ProductBarcodeRepository {
    let client: SupabaseClient

    func getByProductId(id: Int) async throws -> [ProductBarcode.JoinedWithCreator] {
        try await client
            .from(.productBarcodes)
            .select(ProductBarcode.getQuery(.joinedCreator(false)))
            .eq("product_id", value: id)
            .execute()
            .value
    }

    func addToProduct(product: Product.Joined, barcode: Barcode) async throws -> ProductBarcode.JoinedWithCreator {
        try await client
            .from(.productBarcodes)
            .insert(ProductBarcode.NewRequest(product: product, barcode: barcode))
            .select(ProductBarcode.getQuery(.joinedCreator(false)))
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .from(.productBarcodes)
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
