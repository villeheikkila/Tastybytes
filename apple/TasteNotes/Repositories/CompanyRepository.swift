import Supabase

protocol CompanyRepository {
    func getById(id: Int) async -> Result<Company, Error>
    func getJoinedById(id: Int) async -> Result<Company.Joined, Error>
    func insert(newCompany: Company.NewRequest) async -> Result<Company, Error>
    func update(updateRequest: Company.UpdateRequest) async -> Result<Company.Joined, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Company], Error>
    func getSummaryById(id: Int) async -> Result<Company.Summary, Error>
}

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient

    func getById(id: Int) async -> Result<Company, Error> {
        do {
            let response: Company = try await client
                .database
                .from(Company.getQuery(.tableName))
                .select(columns: Company.getQuery(.saved(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getJoinedById(id: Int) async -> Result<Company.Joined, Error> {
        do {
            let response: Company.Joined = try await client
                .database
                .from(Company.getQuery(.tableName))
                .select(columns: Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newCompany: Company.NewRequest) async -> Result<Company, Error> {
        do {
            let response: Company = try await client
                .database
                .from(Company.getQuery(.tableName))
                .insert(values: newCompany, returning: .representation)
                .select(columns: Company.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func update(updateRequest: Company.UpdateRequest) async -> Result<Company.Joined, Error> {
        do {
            let response: Company.Joined = try await client
                .database
                .from(Company.getQuery(.tableName))
                .update(values: updateRequest)
                .eq(column: "id", value: updateRequest.id)
                .select(columns: Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
                .single()
                .execute()
                .value
            
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
            let response: [Company] = try await client
                .database
                .from(Company.getQuery(.tableName))
                .select(columns: Company.getQuery(.saved(false)))
                .ilike(column: "name", value: "%\(searchTerm)%")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getSummaryById(id: Int) async -> Result<Company.Summary, Error> {
        do {
            let response: Company.Summary = try await client
                .database
                .rpc(fn: "fnc__get_company_summary", params: Company.SummaryRequest(id: id))
                .select()
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
