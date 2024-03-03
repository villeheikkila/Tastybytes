import Models

public protocol ReportRepository: Sendable {
    func getAll() async -> Result<[Report], Error>
    func insert(report: Report.NewRequest) async -> Result<Void, Error>
}
