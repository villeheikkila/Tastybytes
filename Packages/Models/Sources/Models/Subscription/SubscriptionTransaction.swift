import Foundation
import StoreKit

public struct SubscriptionTransaction: Codable, Identifiable, Sendable {
    public let id: UInt64
    public let originalId: UInt64
    public let expirationDate: Date?
    public let jsonRepresentation: String

    public init(transaction: StoreKit.Transaction) {
        id = transaction.id
        originalId = transaction.originalID
        expirationDate = transaction.expirationDate
        jsonRepresentation = String(data: transaction.jsonRepresentation, encoding: .utf8) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case originalId = "original_id"
        case expirationDate = "expiration_date"
        case jsonRepresentation = "json_representation"
    }
}
