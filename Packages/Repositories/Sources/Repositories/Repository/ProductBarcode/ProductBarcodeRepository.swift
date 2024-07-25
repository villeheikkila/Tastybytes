import Models

public protocol ProductBarcodeRepository: Sendable {
    func getByProductId(id: Product.Barcode.Id) async throws -> [Product.Barcode.JoinedWithCreator]
    @discardableResult func addToProduct(id: Product.Id, barcode: Barcode) async throws -> Product.Barcode.JoinedWithCreator
    func delete(id: Product.Barcode.Id) async throws
}
