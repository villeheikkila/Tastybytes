import Foundation
import Models
internal import Supabase

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Int) async throws -> Company {
        try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getJoinedById(id: Int) async throws -> Company.Joined {
        try await client
            .from(.companies)
            .select(Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Int) async throws -> Company.Detailed {
        try await client
            .from(.companies)
            .select(Company.getQuery(.detailed(false)))
            .eq("id", value: id)
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

    func uploadLogo(companyId: Int, data: Data) async throws -> ImageEntity {
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
            .eq("id", value: updateRequest.id)
            .select(Company.getQuery(.detailed(false)))
            .single()
            .execute()
            .value
    }

    func deleteEditSuggestion(editSuggestion: Company.EditSuggestion) async throws {
        try await client
            .from(.companyEditSuggestions)
            .delete()
            .eq("id", value: editSuggestion.id)
            .execute()
    }

    func resolveEditSuggestion(editSuggestion: Company.EditSuggestion) async throws {
        try await client
            .from(.companyEditSuggestions)
            .update(Report.ResolveRequest(resolvedAt: Date.now))
            .eq("id", value: editSuggestion.id)
            .execute()
    }

    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async throws {
        try await client
            .from(.companyEditSuggestions)
            .insert(updateRequest)
            .execute()
    }

    func delete(id: Int) async throws {
        try await client
            .from(.companies)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func verification(id: Int, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifyCompany, params: Company.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }

    func search(searchTerm: String) async throws -> [Company] {
        let searchString = searchTerm
            .split(separator: " ")
            .map { "\($0.trimmingCharacters(in: .whitespaces)):*" }
            .joined(separator: " & ")

        return try await client
            .from(.companies)
            .select(Company.getQuery(.saved(false)))
            .textSearch("name", query: searchString)
            .execute()
            .value
    }

    func getSummaryById(id: Int) async throws -> Summary {
        try await client
            .rpc(fn: .getCompanySummary, params: Company.SummaryRequest(id: id))
            .select()
            .limit(1)
            .single()
            .execute()
            .value
    }
}
