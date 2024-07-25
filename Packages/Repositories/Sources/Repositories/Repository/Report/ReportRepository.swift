import Foundation
import Models

public protocol ReportRepository: Sendable {
    func getAll() async throws -> [Report.Joined]
    func insert(report: Report.NewRequest) async throws
    func delete(id: Report.Id) async throws
    @discardableResult func resolve(id: Report.Id) async throws -> Report.Joined
}
