import Foundation
import Models
internal import Supabase

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Company.Id) async throws -> Company.Saved {
        try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getAll() async throws -> [Company.Saved] {
        try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .order("created_at", ascending: false)
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

    func insert(newCompany: Company.NewRequest) async throws -> Company.Saved {
        try await client
            .from(.companies)
            .insert(newCompany, returning: .representation)
            .select(Company.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func getUnverified() async throws -> [Company.Saved] {
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

    func search(filterCompanies: [Company.Saved] = [], searchTerm: String) async throws -> [Company.Saved] {
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

        let value: [Company.Saved] = try await query
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

    func makeCompanySubsidiaryOf(id: Company.Id, subsidiaryOfId: Company.Id) async throws {
        try await client
            .from(.companies)
            .update(["id": id, "subsidiary_of": subsidiaryOfId])
            .eq("id", value: id.rawValue)
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

    func mergeCompanies(id: Company.Id, mergeToId: Company.Id) async throws {
        try await client
            .rpc(fn: .mergeCompanies, params: ["p_company_id": id, "p_merge_to_company_id": mergeToId])
            .execute()
            .value
    }
    
    func addLogo(id: Company.Id, logoId: Logo.Id) async throws {
        try await client
            .from(.companiesLogos)
            .insert(["company_id": AnyJSON(id), "logo_id": AnyJSON(logoId)])
            .execute()
            .value
    }
    
    func removeLogo(id: Company.Id, logoId: Logo.Id) async throws {
        try await client
            .from(.companiesLogos)
            .delete()
            .eq("company_id", value: id.rawValue)
            .eq("logo_id", value: logoId.rawValue)
            .execute()
            .value
    }
}
