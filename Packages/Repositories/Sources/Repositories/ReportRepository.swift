import Foundation
import Models
import Supabase

public protocol ReportRepository {
    func insert(report: Report.NewRequest) async -> Result<Void, Error>
}

public struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    public func insert(report: Report.NewRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.reports)
                .insert(values: report, returning: .none)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

extension Report {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.reports.rawValue
        let saved = "id, message"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
