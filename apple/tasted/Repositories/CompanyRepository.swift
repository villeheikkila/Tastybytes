struct SupabaseCompanyRepository {
    private let tableName = "companies"
    private let saved = "id, name"
    
    func loadAll() async throws -> [Company] {
        return try await Supabase.client.database
            .from(tableName)
            .select(columns: saved)
            .execute()
            .decoded(to: [Company].self)
    }
    
    func insert(newCompany: NewCompany) async throws -> Company {
        return try await Supabase.client.database.from(tableName)
            .insert(values: newCompany, returning: .representation)
            .select(columns: saved)
            .single()
            .execute()
            .decoded(to: Company.self)
    }
}

