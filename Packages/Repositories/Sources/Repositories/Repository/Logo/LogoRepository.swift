import Foundation
import Models

public protocol LogoRepository: Sendable {
    func insert(data: Data, width: Int, height: Int, blurHash: String, label: String) async throws -> Logo.Saved
    func getAll() async throws -> [Logo.Saved]
    func update(id: Logo.Id, label: String) async throws -> Logo.Saved
    func delete(id: Logo.Id) async throws
}
