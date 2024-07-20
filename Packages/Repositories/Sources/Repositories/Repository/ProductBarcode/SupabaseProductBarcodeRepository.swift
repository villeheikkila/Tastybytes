import Models
internal import Supabase

struct SupabaseProductBarcodeRepository: ProductBarcodeRepository {
    let client: SupabaseClient

    func getByProductId(id: Product.Barcode.Id) async throws -> [Product.Barcode.JoinedWithCreator] {
        try await client
            .from(.productBarcodes)
            .select(Product.Barcode.getQuery(.joinedCreator(false)))
            .eq("product_id", value: id.rawValue)
            .execute()
            .value
    }

    func addToProduct(product: ProductProtocol, barcode: Barcode) async throws -> Product.Barcode.JoinedWithCreator {
        try await client
            .from(.productBarcodes)
            .insert(Product.Barcode.NewRequest(product: product, barcode: barcode))
            .select(Product.Barcode.getQuery(.joinedCreator(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Product.Barcode.Id) async throws {
        try await client
            .from(.productBarcodes)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }
}
