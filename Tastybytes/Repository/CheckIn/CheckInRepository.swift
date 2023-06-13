import Foundation
import Supabase
import SupabaseStorage

enum CheckInQueryType {
  case paginated(Int, Int)
  case all
}

protocol CheckInRepository {
  func getActivityFeed(from: Int, to: Int) async -> Result<[CheckIn], Error>
  func getById(id: Int) async -> Result<CheckIn, Error>
  func getByProfileId(id: UUID, queryType: CheckInQueryType) async -> Result<[CheckIn], Error>
  func getByProductId(id: Int, from: Int, to: Int) async -> Result<[CheckIn], Error>
  func getByLocation(locationId: UUID, from: Int, to: Int) async -> Result<[CheckIn], Error>
  func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error>
  func update(updateCheckInParams: CheckIn.UpdateRequest) async -> Result<CheckIn, Error>
  func delete(id: Int) async -> Result<Void, Error>
  func deleteAsModerator(checkIn: CheckIn) async -> Result<Void, Error>
  func getSummaryByProfileId(id: UUID) async -> Result<ProfileSummary, Error>
  func uploadImage(id: Int, data: Data, userId: UUID) async -> Result<String, Error>
}

struct SupabaseCheckInRepository: CheckInRepository {
  let client: SupabaseClient

  func getActivityFeed(from: Int, to: Int) async -> Result<[CheckIn], Error> {
    do {
      let response: [CheckIn] = try await client
        .database
        .rpc(function: .getActivityFeed)
        .select(columns: CheckIn.getQuery(.joined(false)))
        .range(from: from, to: to)
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func getByProfileId(id: UUID, queryType: CheckInQueryType) async -> Result<[CheckIn], Error> {
    do {
      let queryBuilder = client
        .database
        .from(CheckIn.getQuery(.tableName))
        .select(columns: CheckIn.getQuery(.joined(false)))
        .eq(column: "created_by", value: id.uuidString.lowercased())
        .order(column: "id", ascending: false)

      switch queryType {
      case .all:
        let response: [CheckIn] = try await queryBuilder
          .execute()
          .value
        return .success(response)
      case let .paginated(from, to):
        let response: [CheckIn] = try await queryBuilder
          .range(from: from, to: to)
          .execute()
          .value
        return .success(response)
      }
    } catch {
      return .failure(error)
    }
  }

  func getByProductId(id: Int, from: Int, to: Int) async -> Result<[CheckIn], Error> {
    do {
      let response: [CheckIn] = try await client
        .database
        .from(CheckIn.getQuery(.tableName))
        .select(columns: CheckIn.getQuery(.joined(false)))
        .eq(column: "product_id", value: id)
        .order(column: "created_at", ascending: false)
        .range(from: from, to: to)
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func getByLocation(locationId: UUID, from: Int, to: Int) async -> Result<[CheckIn], Error> {
    do {
      let response: [CheckIn] = try await client
        .database
        .from(CheckIn.getQuery(.tableName))
        .select(columns: CheckIn.getQuery(.joined(false)))
        .eq(column: "location_id", value: locationId.uuidString)
        .order(column: "created_at", ascending: false)
        .range(from: from, to: to)
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func getById(id: Int) async -> Result<CheckIn, Error> {
    do {
      let response: CheckIn = try await client
        .database
        .from(CheckIn.getQuery(.tableName))
        .select(columns: CheckIn.getQuery(.joined(false)))
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

  func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error> {
    do {
      let createdCheckIn: IntId = try await client
        .database
        .rpc(fn: "fnc__create_check_in", params: newCheckInParams)
        .select(columns: "id")
        .limit(count: 1)
        .single()
        .execute()
        .value

      return await getById(id: createdCheckIn.id)
    } catch {
      return .failure(error)
    }
  }

  func update(updateCheckInParams: CheckIn.UpdateRequest) async -> Result<CheckIn, Error> {
    do {
      let response: CheckIn = try await client
        .database
        .rpc(fn: "fnc__update_check_in", params: updateCheckInParams)
        .select(columns: CheckIn.getQuery(.joined(false)))
        .limit(count: 1)
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
        .from(CheckIn.getQuery(.tableName))
        .delete()
        .eq(column: "id", value: id)
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func deleteAsModerator(checkIn: CheckIn) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__delete_check_in_as_moderator", params: CheckIn.DeleteAsAdminRequest(checkIn: checkIn))
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func getSummaryByProfileId(id: UUID) async -> Result<ProfileSummary, Error> {
    do {
      let response: ProfileSummary = try await client
        .database
        .rpc(fn: "fnc__get_profile_summary", params: ProfileSummary.GetRequest(profileId: id))
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

  func uploadImage(id: Int, data: Data, userId: UUID) async -> Result<String, Error> {
    do {
      let fileName = "\(id)_\(Int(Date().timeIntervalSince1970)).jpeg"
      let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

      _ = try await client
        .storage
        .from(id: CheckIn.getQuery(.imageBucket))
        .upload(
          path: "\(userId.uuidString.lowercased())/\(fileName)",
          file: file,
          fileOptions: FileOptions(cacheControl: "86400")
        )

      return .success(fileName)
    } catch {
      return .failure(error)
    }
  }
}