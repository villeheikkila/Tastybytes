import Supabase

protocol CompanyRepository {
    func getById(id: Int) async throws -> CompanyJoined
    func insert(newCompany: NewCompany) async throws -> Company
    func delete(id: Int) async throws -> Void
    func search(searchTerm: String) async throws -> [Company]
    func getSummaryById(id: Int) async throws -> CompanySummary
}

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient
    private let tableName = Company.getQuery(.tableName)
    private let saved = Company.getQuery(.saved(false))
    private let joined = Company.getQuery(.joinedBrandSubcategoriesOwner(false))
    
    func getById(id: Int) async throws -> CompanyJoined {
        return try await client
            .database
            .from(tableName)
            .select(columns: joined)
            .eq(column: "id", value: id)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CompanyJoined.self)
    }
    
    func insert(newCompany: NewCompany) async throws -> Company {
        return try await client
            .database
            .from(tableName)
            .insert(values: newCompany, returning: .representation)
            .select(columns: saved)
            .single()
            .execute()
            .decoded(to: Company.self)
    }
    
    func delete(id: Int) async throws -> Void {
       try await client
            .database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
    
    func search(searchTerm: String) async throws -> [Company] {
        return try await client
            .database
            .from(tableName)
            .select(columns: saved)
            .ilike(column: "name", value: "%\(searchTerm)%")
            .execute()
            .decoded(to: [Company].self)
    }
    
    func getSummaryById(id: Int) async throws -> CompanySummary {
        return try await client
            .database
            .rpc(fn: "fnc__get_company_summary", params: GetCompanySummaryParams(id: id))
            .select()
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: CompanySummary.self)
    }
}

