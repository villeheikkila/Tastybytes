import Extensions
import Foundation

public protocol BarcodeProtocol {
    var barcode: String { get }
    var type: String { get }
}

public extension BarcodeProtocol {
    func isSameAs(_ barcode: BarcodeProtocol?) -> Bool {
        self.barcode == barcode?.barcode && type == barcode?.type
    }
}

public struct Barcode: Codable, Hashable, Sendable, Identifiable, BarcodeProtocol {
    enum CodingKeys: String, CodingKey {
        case barcode, type
    }

    public let barcode: String
    public let type: String

    public init(barcode: String, type: String) {
        self.barcode = barcode
        self.type = type
    }

    public var id: String {
        "\(type)_\(barcode)"
    }
}
