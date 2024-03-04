import Foundation
import Models
import Supabase

struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    func getAll() async -> Result<[Report], Error> {
        do {
            let response: [Report] = try await client
                .database
                .from(.reports)
                .select(Report.getQuery(.joined(false)))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(report: Report.NewRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.reports)
                .insert(report, returning: .none)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
