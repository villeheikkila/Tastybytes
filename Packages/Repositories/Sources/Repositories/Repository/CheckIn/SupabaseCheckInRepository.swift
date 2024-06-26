import Foundation
import Models
import Supabase

struct SupabaseCheckInRepository: CheckInRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getActivityFeed(query: ActivityFeedQueryType) async -> Result<[CheckIn], Error> {
        do {
            let partialQuery = client
                .from(.viewActivityFeed)
                .select(CheckIn.getQuery(.joined(false)))

            let range = switch query {
            case let .paginated(from, to):
                partialQuery.range(from: from, to: to)
            case let .afterId(id):
                partialQuery.gt("id", value: id)
            }

            let response: [CheckIn] = try await range
                .order("check_in_at", ascending: false)
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
                .from(.checkIns)
                .select(CheckIn.getQuery(.joined(false)))

            let filter = queryBuilder
                .eq("created_by", value: id.uuidString.lowercased())

            let conditionalFilters = if case let .dateRange(_, _, dateRange) = queryType {
                filter.gte("check_in_at", value: dateRange.lowerBound.formatted(.iso8601))
                    .lte("check_in_at", value: dateRange.upperBound.formatted(.iso8601))
            } else if case let .location(_, _, location) = queryType {
                filter.eq("location_id", value: location.id)
            } else {
                filter
            }

            let ordered = conditionalFilters.order("check_in_at", ascending: false)

            let query = if case let .paginated(from, to) = queryType {
                ordered.range(from: from, to: to)
            } else if case let .dateRange(from, to, _) = queryType {
                ordered.range(from: from, to: to)
            } else if case let .location(from, to, _) = queryType {
                ordered.range(from: from, to: to)
            } else {
                ordered
            }

            let response: [CheckIn] = try await query
                .execute()
                .value
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByProductId(id: Int, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response: [CheckIn] = try await client
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

    func getCheckInImages(id: UUID, from: Int, to: Int) async -> Result<[ImageEntity.JoinedCheckIn], Error> {
        do {
            let response: [ImageEntity.JoinedCheckIn] = try await client
                .from(.checkInImages)
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

    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async -> Result<[ImageEntity.JoinedCheckIn], Error> {
        do {
            let response: [ImageEntity.JoinedCheckIn] = try await client
                .from(.checkInImages)
                .select(CheckIn.getQuery(.image(false)))
                .eq(by.column, value: by.id)
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByLocation(locationId: UUID, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error> {
        do {
            let response: [CheckIn] = try await client
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

    func uploadImage(id: Int, data: Data, userId: UUID, blurHash: String?) async -> Result<ImageEntity, Error> {
        do {
            let fileName = "\(id)_\(Int(Date().timeIntervalSince1970)).jpeg"
            let path = "\(userId.uuidString.lowercased())/\(fileName)"

            _ = try await client
                .storage
                .from(.checkIns)
                .upload(path: path, file: data, options: .init(cacheControl: "max-age=3600", contentType: "image/jpeg"))

            if let blurHash {
                return await updateImageBlurHash(file: path, blurHash: blurHash)
            } else {
                return await imageEntityRepository.getByFileName(from: .checkInImages, fileName: path)
            }
        } catch {
            return .failure(error)
        }
    }

    func updateImageBlurHash(file: String, blurHash: String) async -> Result<ImageEntity, Error> {
        do {
            let response: ImageEntity = try await client
                .rpc(fn: .updateCheckInImageBlurHash, params: UpdateCheckInImageBlurHashParams(file: file, blurHash: blurHash))
                .select(ImageEntity.getQuery(.saved(nil)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}

struct UpdateCheckInImageBlurHashParams: Codable {
    let file: String
    let blurHash: String

    enum CodingKeys: String, CodingKey {
        case file = "p_file"
        case blurHash = "p_blur_hash"
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
            "check_ins.product_id"
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
