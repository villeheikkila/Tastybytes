import Models

public protocol ReportRepository: Sendable {
    func getAll() async -> Result<[Report], Error>
    func insert(report: Report.NewRequest) async -> Result<Void, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func resolve(id: Int) async -> Result<Report, Error>
}
