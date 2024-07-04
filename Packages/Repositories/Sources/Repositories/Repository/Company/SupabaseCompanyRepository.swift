import Foundation
import Models
internal import Supabase

struct SupabaseCompanyRepository: CompanyRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Int) async -> Result<Company, Error> {
        do {
            let response: Company = try await client
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

    func getManagementDataById(id: Int) async -> Result<Company.Management, Error> {
        do {
            let response: Company.Management = try await client
                .from(.companies)
                .select(Company.getQuery(.management(false)))
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

    func uploadLogo(companyId: Int, data: Data) async -> Result<ImageEntity, Error> {
        do {
            let fileName = "\(companyId)_\(Date.now.timeIntervalSince1970).jpeg"

            try await client
                .storage
                .from(.companyLogos)
                .upload(path: fileName, file: data, options: .init(contentType: "image/jpeg"))

            return await imageEntityRepository.getByFileName(from: .companyLogos, fileName: fileName)
        } catch {
            return .failure(error)
        }
    }

    func getUnverified() async -> Result<[Company], Error> {
        do {
            let response: [Company] = try await client
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

    func update(updateRequest: Company.UpdateRequest) async -> Result<Company.Management, Error> {
        do {
            let response: Company.Management = try await client
                .from(.companies)
                .update(updateRequest)
                .eq("id", value: updateRequest.id)
                .select(Company.getQuery(.management(false)))
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
