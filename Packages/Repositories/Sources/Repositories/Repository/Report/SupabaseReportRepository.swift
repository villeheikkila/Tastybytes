import Foundation
import Models
internal import Supabase

struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    func getAll(_ filter: ReportFilter? = nil) async throws -> [Report.Joined] {
        let query = client
            .from(.reports)
            .select(Report.getQuery(.joined(false)))
            .is("resolved_at", value: nil)

        let filtered = if let filter {
            switch filter {
            case let .company(id):
                query.eq(filter.column, value: id.rawValue)
            case let .checkIn(id):
                query.eq(filter.column, value: id.rawValue)
            case let .product(id):
                query.eq(filter.column, value: id.rawValue)
            case let .comment(id):
                query.eq(filter.column, value: id.rawValue)
            case let .brand(id):
                query.eq(filter.column, value: id.rawValue)
            case let .location(id):
                query.eq(filter.column, value: id.rawValue)
            case let .subBrand(id):
                query.eq(filter.column, value: id.rawValue)
            case let .checkInImage(id):
                query.eq(filter.column, value: id.rawValue)
            case let .profile(id):
                query.eq(filter.column, value: id.rawValue)
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

    func delete(id: Report.Id) async throws {
        try await client
            .from(.reports)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func resolve(id: Report.Id) async throws -> Report.Joined {
        try await client
            .from(.reports)
            .update(Report.ResolveRequest(resolvedAt: Date.now))
            .eq("id", value: id.rawValue)
            .select(Report.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }
}
