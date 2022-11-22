import Foundation
import Supabase
import SupabaseStorage

protocol CheckInRepository {
    func getActivityFeed(from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getById(id: Int) async -> Result<CheckIn, Error>
    func getByProfileId(id: UUID, from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getByProductId(id: Int, from: Int, to: Int) async -> Result<[CheckIn], Error>
    func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error>
    func update(updateCheckInParams: CheckIn.UpdateRequest) async -> Result<CheckIn, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func getSummaryByProfileId(id: UUID) async -> Result<ProfileSummary, Error>
    func uploadImage(id: Int, data: Data) async -> Result<Void, Error>
}

struct SupabaseCheckInRepository: CheckInRepository {
    let client: SupabaseClient

    func getActivityFeed(from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__get_activity_feed")
                .select(columns: CheckIn.getQuery(.joined(false)))
                .range(from: from, to: to)
                .execute()
                .decoded(to: [CheckIn].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByProfileId(id: UUID, from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response = try await client
                .database
                .from(CheckIn.getQuery(.tableName))
                .select(columns: CheckIn.getQuery(.joined(false)))
                .eq(column: "created_by", value: id.uuidString.lowercased())
                .order(column: "id", ascending: false)
                .range(from: from, to: to)
                .execute()
                .decoded(to: [CheckIn].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByProductId(id: Int, from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response = try await client
                .database
                .from(CheckIn.getQuery(.tableName))
                .select(columns: CheckIn.getQuery(.joined(false)))
                .eq(column: "product_id", value: id)
                .order(column: "created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .decoded(to: [CheckIn].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getById(id: Int) async -> Result<CheckIn, Error> {
        do {
            let response = try await client
                .database
                .from(CheckIn.getQuery(.tableName))
                .select(columns: CheckIn.getQuery(.joined(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CheckIn.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error> {
        do {
            let createdCheckIn = try await client
                .database
                .rpc(fn: "fnc__create_check_in", params: newCheckInParams)
                .select(columns: "id")
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: DecodableId.self)

            return await getById(id: createdCheckIn.id)
        } catch {
            return .failure(error)
        }
    }

    func update(updateCheckInParams: CheckIn.UpdateRequest) async -> Result<CheckIn, Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__update_check_in", params: updateCheckInParams)
                .select(columns: CheckIn.getQuery(.joined(false)))
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: CheckIn.self)

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

    func getSummaryByProfileId(id: UUID) async -> Result<ProfileSummary, Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__get_profile_summary", params: ProfileSummary.GetRequest(profileId: id))
                .select()
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: ProfileSummary.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadImage(id: Int, data: Data) async -> Result<Void, Error> {
        let profileId = repository.auth.getCurrentUserId()

        let file = File(
            name: "\(id).jpeg", data: data, fileName: "\(id).jpeg", contentType: "image/jpeg")

        do {
            _ = try await client
                .storage
                .from(id: "check-ins")
                .upload(
                    path: "\(profileId.uuidString.lowercased())/\(id).jpeg", file: file, fileOptions: nil
                )

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
