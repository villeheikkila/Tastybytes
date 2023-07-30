import Foundation
import Supabase

protocol ReportRepository {
    func insert(report: Report.NewRequest) async -> Result<Void, Error>
}

struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    func insert(report: Report.NewRequest) async -> Result<Void, Error> {
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
