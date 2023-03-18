import Foundation
import Supabase
import SupabaseStorage

protocol CompanyRepository {
  func getById(id: Int) async -> Result<Company, Error>
  func getJoinedById(id: Int) async -> Result<Company.Joined, Error>
  func getUnverified() async -> Result<[Company], Error>
  func insert(newCompany: Company.NewRequest) async -> Result<Company, Error>
  func update(updateRequest: Company.UpdateRequest) async -> Result<Company.Joined, Error>
  func delete(id: Int) async -> Result<Void, Error>
  func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
  func search(searchTerm: String) async -> Result<[Company], Error>
  func getSummaryById(id: Int) async -> Result<Summary, Error>
  func uploadLogo(companyId: Int, data: Data) async -> Result<String, Error>
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

  func uploadLogo(companyId: Int, data: Data) async -> Result<String, Error> {
    do {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy_MM_dd_HH_mm"
      let date = Date()
      let timestamp = formatter.string(from: date)
      let fileName = "\(companyId)_\(timestamp).jpeg"
      let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

      _ = try await client
        .storage
        .from(id: Company.getQuery(.logoBucket))
        .upload(path: fileName, file: file, fileOptions: nil)

      return .success(fileName)
    } catch {
      return .failure(error)
    }
  }

  func getUnverified() async -> Result<[Company], Error> {
    do {
      let response: [Company] = try await client
        .database
        .from(Company.getQuery(.tableName))
        .select(columns: Company.getQuery(.saved(false)))
        .eq(column: "is_verified", value: false)
        .order(column: "created_at", ascending: false)
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

  func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__verify_company", params: Company.VerifyRequest(id: id, isVerified: isVerified))
        .single()
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
        .textSearch(column: "name", query: searchTerm + ":*")
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
