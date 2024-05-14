import Foundation
import Models
import Supabase

struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    func getAll() async -> Result<[Report], Error> {
        do {
            let response: [Report] = try await client
                .from(.reports)
                .select(Report.getQuery(.joined(false)))
                .is("resolved_at", value: nil)
                .order("created_at", ascending: false)
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
                .from(.reports)
                .insert(report, returning: .none)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .from(.reports)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func resolve(id: Int) async -> Result<Report, Error> {
        do {
            let response: Report = try await client
                .from(.reports)
                .update(Report.ResolveRequest(resolvedAt: Date.now))
                .eq("id", value: id)
                .select(Report.getQuery(.joined(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
