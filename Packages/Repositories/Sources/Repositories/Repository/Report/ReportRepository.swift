import Models

public protocol ReportRepository {
    func insert(report: Report.NewRequest) async -> Result<Void, Error>
}
