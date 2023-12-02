import Foundation
import Models
import Supabase

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient

    func getById(id: Int) async -> Result<Company, Error> {
        do {
            let response: Company = try await client
                .database
                .from(.companies)
                .select(Company.getQuery(.saved(false)))
                .eq("id", value: id)
                .limit(1)
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
                .from(.companies)
                .select(Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
                .eq("id", value: id)
                .limit(1)
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
                .from(.companies)
                .insert(newCompany, returning: .representation)
                .select(Company.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadLogo(companyId: Int, data: Data) async -> Result<String, Error> {
        do {
            let fileName = "\(companyId)_\(Date().customFormat(.fileNameSuffix)).jpeg"
            let fileOptions = FileOptions(cacheControl: "604800", contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.logos)
                .upload(path: fileName, file: data, options: fileOptions)

            return .success(fileName)
        } catch {
            return .failure(error)
        }
    }

    func getUnverified() async -> Result<[Company], Error> {
        do {
            let response: [Company] = try await client
                .database
                .from(.companies)
                .select(Company.getQuery(.saved(false)))
                .eq("is_verified", value: false)
                .order("created_at", ascending: false)
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
                .from(.companies)
                .update(updateRequest)
                .eq("id", value: updateRequest.id)
                .select(Company.getQuery(.joinedBrandSubcategoriesOwner(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func editSuggestion(updateRequest: Company.EditSuggestionRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.companyEditSuggestions)
                .insert(updateRequest)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.companies)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .verifyCompany, params: Company.VerifyRequest(id: id, isVerified: isVerified))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func search(searchTerm: String) async -> Result<[Company], Error> {
        do {
            let searchString = searchTerm
                .split(separator: " ")
                .map { "\($0.trimmingCharacters(in: .whitespaces)):*" }
                .joined(separator: " & ")

            let response: [Company] = try await client
                .database
                .from(.companies)
                .select(Company.getQuery(.saved(false)))
                .textSearch("name", query: searchString)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getSummaryById(id: Int) async -> Result<Summary, Error> {
        do {
            let response: Summary = try await client
                .database
                .rpc(fn: .getCompanySummary, params: Company.SummaryRequest(id: id))
                .select()
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
