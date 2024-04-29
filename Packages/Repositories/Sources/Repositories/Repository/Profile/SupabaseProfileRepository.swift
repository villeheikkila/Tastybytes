import Foundation
import Models
import Supabase

struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: UUID) async -> Result<Profile, Error> {
        do {
            let response: Profile = try await client
                .from(.profiles)
                .select(Profile.getQuery(.minimal(false)))
                .eq("id", value: id.uuidString.lowercased())
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getCurrentUser() async -> Result<Profile.Extended, Error> {
        do {
            let response: Profile.Extended = try await client
                .rpc(fn: .getCurrentProfile)
                .select(Profile.getQuery(.extended(false)))
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func update(update: Profile.UpdateRequest) async -> Result<Profile.Extended, Error> {
        do {
            let response: Profile.Extended = try await client
                .from(.profiles)
                .update(update, returning: .representation)
                /*
                 Supabase responds with status code 46 if where clause is not specified for an update.
                 However we do not need top pass the real id here because it is assigned by trigger.
                 RLS makes sure that user can only ever update their own profiles.
                 */
                .notEquals("id", value: UUID().uuidString)
                .select(Profile.getQuery(.extended(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func updateSettings(update: ProfileSettings.UpdateRequest) async -> Result<ProfileSettings, Error> {
        do {
            let response: ProfileSettings = try await client
                .from(.profileSettings)
                .update(update,
                        returning: .representation)
                /*
                 Supabase responds with status code 46 if where clause is not specified for an update.
                 However we do not need top pass the real id here because it is assigned by trigger.
                 RLS makes sure that user can only ever update their own profiles.
                 */
                .notEquals("id", value: UUID().uuidString)
                .select(ProfileSettings.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getContributions(userId: UUID) async -> Result<Contributions, Error> {
        do {
            let response: Contributions = try await client
                .rpc(fn: .getContributionsByUser, params: Contributions.ContributionsParams(id: userId))
                .select(Contributions.getQuery(.value))
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getCategoryStatistics(userId: UUID) async -> Result<[CategoryStatistics], Error> {
        do {
            let response: [CategoryStatistics] = try await client
                .rpc(
                    fn: .getCategoryStats,
                    params: CategoryStatistics.CategoryStatisticsParams(id: userId)
                )
                .select(CategoryStatistics.getQuery(.value))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getSubcategoryStatistics(userId: UUID,
                                  categoryId: Int) async -> Result<[SubcategoryStatistics], Error>
    {
        do {
            let response: [SubcategoryStatistics] = try await client
                .rpc(
                    fn: .getSubcategoryStats,
                    params: SubcategoryStatistics.SubcategoryStatisticsParams(userId: userId, categoryId: categoryId)
                )
                .select(SubcategoryStatistics.getQuery(.value))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func currentUserExport() async -> Result<String, Error> {
        do {
            let csv = try await client
                .rpc(fn: .exportData)
                .csv()
                .execute()
                .data

            if let string = String(data: csv, encoding: .utf8) {
                return .success(string)
            }

            throw DataConversionError.invalidData
        } catch {
            return .failure(error)
        }
    }

    func search(searchTerm: String, currentUserId: UUID? = nil) async -> Result<[Profile], Error> {
        do {
            let query = client
                .from(.profiles)
                .select(Profile.getQuery(.minimal(false)))
                .ilike("search", pattern: "%\(searchTerm)%")

            if let currentUserId {
                let response: [Profile] = try await query
                    .not("id", operator: .eq, value: currentUserId.uuidString)
                    .execute().value
                return .success(response)
            }

            let response: [Profile] = try await query.execute().value
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadAvatar(userId: UUID, data: Data) async -> Result<ImageEntity, Error> {
        do {
            let fileName = "\(Int(Date().timeIntervalSince1970)).jpeg"
            let fileOptions = FileOptions(cacheControl: "604800", contentType: "image/jpeg")
            let path = "\(userId.uuidString.lowercased())/\(fileName)"

            _ = try await client
                .storage
                .from(.avatars)
                .upload(path: path, file: data, options: fileOptions)

            return await imageEntityRepository.getByFileName(from: .avatars, fileName: path)
        } catch {
            return .failure(error)
        }
    }

    func deleteCurrentAccount() async -> Result<Void, Error> {
        do {
            try await client
                .rpc(fn: .deleteCurrentUser)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func checkIfUsernameIsAvailable(username: String) async -> Result<Bool, Error> {
        do {
            let result: Bool = try await client
                .rpc(
                    fn: .checkIfUsernameIsAvailable,
                    params: Profile.UsernameCheckRequest(username: username)
                )
                .execute()
                .value

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func getTimePeriodStatistics(userId: UUID, timePeriod: StatisticsTimePeriod) async
        -> Result<TimePeriodStatistic, Error>
    {
        do {
            let result: TimePeriodStatistic = try await client
                .rpc(
                    fn: .getTimePeriodStatistics,
                    params: TimePeriodStatistic.RequestParams(userId: userId, timePeriod: timePeriod)
                )
                .limit(1)
                .single()
                .execute()
                .value

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func getNumberOfCheckInsByDay(_ request: NumberOfCheckInsByDayRequest) async -> Result<[CheckInsPerDay], Error> {
        do {
            let response: [CheckInsPerDay] = try await client
                .rpc(fn: .getNumberOfCheckInsByDay, params: request)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getNumberOfCheckInsByLocation(userId: UUID) async -> Result<[ProfileTopLocations], Error> {
        do {
            struct Request: Encodable {
                let profileId: UUID

                enum CodingKeys: String, CodingKey {
                    case profileId = "p_profile_id"
                }
            }
            let response: [ProfileTopLocations] = try await client
                .rpc(fn: .getNumberOfCheckInsByLocation, params: Request(profileId: userId))
                .select(Location.getQuery(.topLocations))
                .limit(20)
                .order("check_ins_count", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
