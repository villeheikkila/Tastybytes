import Models

public protocol ProductBarcodeRepository: Sendable {
    func getByProductId(id: Int) async -> Result<[ProductBarcode.JoinedWithCreator], Error>
    func addToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error>
    func delete(id: Int) async -> Result<Void, Error>
}
