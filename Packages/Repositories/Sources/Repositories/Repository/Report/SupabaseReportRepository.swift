import Foundation
import Models
internal import Supabase

struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    func getAll(_ filter: ReportFilter? = nil) async throws -> [Report] {
        let query = client
            .from(.reports)
            .select(Report.getQuery(.joined(false)))
            .is("resolved_at", value: nil)

        let filtered = if let filter {
            switch filter {
            case let .brand(id), let .checkIn(id), let .checkInImage(id), let .comment(id), let .company(id), let .product(id), let .subBrand(id):
                query.eq(filter.column, value: id)
            case let .profile(id):
                query.eq(filter.column, value: id)
            }
        } else {
            query
        }

        return try await filtered
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func insert(report: Report.NewRequest) async throws {
        try await client
            .from(.reports)
            .insert(report, returning: .none)
            .execute()
    }

    func delete(id: Int) async throws {
        try await client
            .from(.reports)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func resolve(id: Int) async throws -> Report {
        try await client
            .from(.reports)
            .update(Report.ResolveRequest(resolvedAt: Date.now))
            .eq("id", value: id)
            .select(Report.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }
}
