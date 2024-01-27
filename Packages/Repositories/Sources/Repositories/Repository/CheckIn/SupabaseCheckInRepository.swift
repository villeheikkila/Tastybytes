import Foundation
import Models
import Supabase

struct SupabaseCheckInRepository: CheckInRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getActivityFeed(from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response: [CheckIn] = try await client
                .database
                .rpc(fn: .getActivityFeed)
                .select(CheckIn.getQuery(.joined(false)))
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
            let queryBuilder = await client
                .database
                .from(.checkIns)
                .select(CheckIn.getQuery(.joined(false)))
                .eq("created_by", value: id.uuidString.lowercased())
                .order("id", ascending: false)

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

    func getByProductId(id: Int, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response: [CheckIn] = try await client
                .database
                .from(segment.table)
                .select(CheckIn.getQuery(.joined(false)))
                .eq("product_id", value: id)
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getCheckInImages(id: UUID, from: Int, to: Int) async -> Result<[CheckIn.Image], Error> {
        do {
            let response: [CheckIn.Image] = try await client
                .database
                .from(.checkIns)
                .select(CheckIn.getQuery(.image(false)))
                .eq("created_by", value: id)
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getCheckInImages(by: CheckInImageQueryType, from: Int,
                          to: Int) async -> Result<[CheckIn.Image], Error>
    {
        do {
            let response: [CheckIn.Image] = try await client
                .database
                .from(.checkIns)
                .select(CheckIn.getQuery(.image(false)))
                .eq(by.column, value: by.id)
                // .notEquals("check_in_images", value: "null")
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByLocation(locationId: UUID, segment: CheckInSegment, from: Int,
                       to: Int) async -> Result<[CheckIn], Error>
    {
        do {
            let response: [CheckIn] = try await client
                .database
                .from(segment.table)
                .select(CheckIn.getQuery(.joined(false)))
                .eq("location_id", value: locationId.uuidString)
                .order("created_at", ascending: false)
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
                .from(.checkIns)
                .select(CheckIn.getQuery(.joined(false)))
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

    func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error> {
        do {
            let createdCheckIn: IntId = try await client
                .database
                .rpc(fn: .createCheckIn, params: newCheckInParams)
                .select("id")
                .limit(1)
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
                .rpc(fn: .updateCheckIn, params: updateCheckInParams)
                .select(CheckIn.getQuery(.joined(false)))
                .limit(1)
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
                .from(.checkIns)
                .delete()
                .eq("id", value: id)
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
                .rpc(fn: .deleteCheckInAsModerator, params: CheckIn.DeleteAsAdminRequest(checkIn: checkIn))
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
                .rpc(fn: .getProfileSummary, params: ProfileSummary.GetRequest(profileId: id))
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

    func uploadImage(id: Int, data: Data, userId: UUID) async -> Result<ImageEntity, Error> {
        do {
            let fileName = "\(id)_\(Int(Date().timeIntervalSince1970)).jpeg"
            let fileOptions = FileOptions(cacheControl: "604800", contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.checkIns)
                .upload(path: "\(userId.uuidString.lowercased())/\(fileName)", file: data, options: fileOptions)

            return await imageEntityRepository.getByFileName(from: .checkInImages, fileName: fileName)
        } catch {
            return .failure(error)
        }
    }
}

public enum CheckInImageQueryType: Sendable {
    case profile(Profile)
    case product(Product.Joined)

    var column: String {
        switch self {
        case .profile:
            "created_by"
        case .product:
            "product_id"
        }
    }

    var id: String {
        switch self {
        case let .profile(profile):
            profile.id.uuidString
        case let .product(product):
            String(product.id)
        }
    }
}
