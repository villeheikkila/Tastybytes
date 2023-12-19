import Models

public protocol ReportRepository: Sendable {
    func insert(report: Report.NewRequest) async -> Result<Void, Error>
}
