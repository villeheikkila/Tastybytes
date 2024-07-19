import Models

public protocol ProductBarcodeRepository: Sendable {
    func getByProductId(id: Int) async throws -> [Product.Barcode.JoinedWithCreator]
    @discardableResult func addToProduct(product: ProductProtocol, barcode: Barcode) async throws -> Product.Barcode.JoinedWithCreator
    func delete(id: Int) async throws
}
