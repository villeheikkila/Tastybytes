import Models

public protocol ProductBarcodeRepository: Sendable {
    func getByProductId(id: Int) async throws -> [ProductBarcode.JoinedWithCreator]
    @discardableResult func addToProduct(product: Product.Joined, barcode: Barcode) async throws -> Barcode
    func delete(id: Int) async throws
}
