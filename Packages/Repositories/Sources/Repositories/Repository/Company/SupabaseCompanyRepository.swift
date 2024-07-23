import Foundation
import Models
internal import Supabase

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Company.Id) async throws -> Company {
        try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getAll() async throws -> [Company] {
        try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .execute()
            .value
    }

    func getJoinedById(id: Company.Id) async throws -> Company.Joined {
        try await client
            .from(.companies)
            .select(Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Company.Id) async throws -> Company.Detailed {
        try await client
            .from(.companies)
            .select(Company.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func insert(newCompany: Company.NewRequest) async throws -> Company {
        try await client
            .from(.companies)
            .insert(newCompany, returning: .representation)
            .select(Company.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func uploadLogo(companyId: Company.Id, data: Data) async throws -> ImageEntity {
        let fileName = "\(companyId)_\(Date.now.timeIntervalSince1970).jpeg"

        try await client
            .storage
            .from(.companyLogos)
            .upload(path: fileName, file: data, options: .init(contentType: "image/jpeg"))

        return try await imageEntityRepository.getByFileName(from: .companyLogos, fileName: fileName)
    }

    func getUnverified() async throws -> [Company] {
        try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .eq("is_verified", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func update(updateRequest: Company.UpdateRequest) async throws -> Company.Detailed {
        try await client
            .from(.companies)
            .update(updateRequest)
            .eq("id", value: updateRequest.id.rawValue)
            .select(Company.getQuery(.detailed(false)))
            .single()
            .execute()
            .value
    }

    func deleteEditSuggestion(editSuggestion: Company.EditSuggestion) async throws {
        try await client
            .from(.companyEditSuggestions)
            .delete()
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func resolveEditSuggestion(editSuggestion: Company.EditSuggestion) async throws {
        try await client
            .from(.companyEditSuggestions)
            .update(Report.ResolveRequest(resolvedAt: Date.now))
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async throws {
        try await client
            .from(.companyEditSuggestions)
            .insert(updateRequest)
            .execute()
    }

    func delete(id: Company.Id) async throws {
        try await client
            .from(.companies)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func verification(id: Company.Id, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifyCompany, params: Company.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }

    func search(filterCompanies: [Company] = [], searchTerm: String) async throws -> [Company] {
        let searchString = searchTerm
            .split(separator: " ")
            .map { "\($0.trimmingCharacters(in: .whitespaces)):*" }
            .joined(separator: " & ")

        let query = client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))

        // TODO: Revisit this later, combined textSearch and filter doesn't seem to work
//        let filtered = if filterCompanies.isEmpty {
//            query
//        } else {
//            query.not("id", operator: .in, value: filterCompanies.map(\.id))
//        }

        let value: [Company] = try await query
            .textSearch("name", query: searchString)
            .execute()
            .value

        return if filterCompanies.isEmpty {
            value
        } else {
            value.filter { !filterCompanies.contains($0) }
        }
    }

    func getSummaryById(id: Company.Id) async throws -> Summary {
        try await client
            .rpc(fn: .getCompanySummary, params: Company.SummaryRequest(id: id))
            .select()
            .limit(1)
            .single()
            .execute()
            .value
    }

    func makeCompanySubsidiaryOf(company: any CompanyProtocol, subsidiaryOf: any CompanyProtocol) async throws {
        struct UpdateRequest: Codable, Sendable {
            public init(company: any CompanyProtocol, subsidiaryOf: any CompanyProtocol) {
                id = company.id
                subsidiary_of = subsidiaryOf.id
            }

            public let id: Company.Id
            public let subsidiary_of: Company.Id
        }
        try await client
            .from(.companies)
            .update(UpdateRequest(company: company, subsidiaryOf: subsidiaryOf))
            .eq("id", value: company.id.rawValue)
            .select(Company.getQuery(.detailed(false)))
            .single()
            .execute()
            .value
    }

    func getEditSuggestions() async throws -> [Company.EditSuggestion] {
        try await client
            .from(.companyEditSuggestions)
            .select(Company.EditSuggestion.getQuery(.joined(false)))
            .execute()
            .value
    }
}
