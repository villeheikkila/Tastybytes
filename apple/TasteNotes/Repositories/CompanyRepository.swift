import Supabase

protocol CompanyRepository {
    func getById(id: Int) async -> Result<Company, Error>
    func getJoinedById(id: Int) async -> Result<CompanyJoined, Error>
    func insert(newCompany: NewCompany) async -> Result<Company, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Company], Error>
    func getSummaryById(id: Int) async -> Result<CompanySummary, Error>
}

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient

    func getById(id: Int) async -> Result<Company, Error> {
        do {
            let response = try await client
                .database
                .from(Company.getQuery(.tableName))
                .select(columns: Company.getQuery(.saved(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: Company.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getJoinedById(id: Int) async -> Result<CompanyJoined, Error> {
        do {
            let response = try await client
                .database
                .from(Company.getQuery(.tableName))
                .select(columns: Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CompanyJoined.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newCompany: NewCompany) async -> Result<Company, Error> {
        do {
            let response = try await client
                .database
                .from(Company.getQuery(.tableName))
                .insert(values: newCompany, returning: .representation)
                .select(columns: Company.getQuery(.saved(false)))
                .single()
                .execute()
                .decoded(to: Company.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(Company.getQuery(.tableName))
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func search(searchTerm: String) async -> Result<[Company], Error> {
        do {
            let response = try await client
                .database
                .from(Company.getQuery(.tableName))
                .select(columns: Company.getQuery(.saved(false)))
                .ilike(column: "name", value: "%\(searchTerm)%")
                .execute()
                .decoded(to: [Company].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getSummaryById(id: Int) async -> Result<CompanySummary, Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__get_company_summary", params: GetCompanySummaryParams(id: id))
                .select()
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CompanySummary.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
