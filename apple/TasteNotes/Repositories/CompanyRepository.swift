import Supabase

protocol CompanyRepository {
    func getById(id: Int) async -> Result<CompanyJoined, Error>
    func insert(newCompany: NewCompany) async -> Result<Company, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Company], Error>
    func getSummaryById(id: Int) async -> Result<CompanySummary, Error>
}

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient
    private let tableName = Company.getQuery(.tableName)
    private let saved = Company.getQuery(.saved(false))
    private let joined = Company.getQuery(.joinedBrandSubcategoriesOwner(false))

    func getById(id: Int) async -> Result<CompanyJoined, Error> {
        do {
            let response = try await client
                .database
                .from(tableName)
                .select(columns: joined)
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
                .from(tableName)
                .insert(values: newCompany, returning: .representation)
                .select(columns: saved)
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
                .from(tableName)
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
                .from(tableName)
                .select(columns: saved)
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
