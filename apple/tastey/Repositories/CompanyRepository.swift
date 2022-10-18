struct SupabaseCompanyRepository {
    private let database = Supabase.client.database
    private let tableName = "companies"
    private let saved = "id, name"
    
    func insert(newCompany: NewCompany) async throws -> Company {
        return try await database
            .from(tableName)
            .insert(values: newCompany, returning: .representation)
            .select(columns: saved)
            .single()
            .execute()
            .decoded(to: Company.self)
    }
    
    func search(searchTerm: String) async throws -> [Company] {
        return try await database
            .from(tableName)
            .select(columns: saved)
            .ilike(column: "name", value: "%\(searchTerm)%")
            .execute()
            .decoded(to: [Company].self)
    }
}

