import Foundation
import Models
import Supabase

struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient

    func getById(id: UUID) async -> Result<Profile, Error> {
        do {
            let response: Profile = try await client
                .database
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
                .database
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
                .database
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
                .database
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
                .database
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
                .database
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
                .database
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
            let csv: String = try await client
                .database
                .rpc(fn: .exportData)
                .csv()
                .execute()
                .value

            return .success(csv)
        } catch {
            return .failure(error)
        }
    }

    func search(searchTerm: String, currentUserId: UUID? = nil) async -> Result<[Profile], Error> {
        do {
            let query = await client
                .database
                .from(.profiles)
                .select(Profile.getQuery(.minimal(false)))
                .ilike("search", value: "%\(searchTerm)%")

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

    func uploadAvatar(userId: UUID, data: Data) async -> Result<String, Error> {
        do {
            let fileName = "\(Int(Date().timeIntervalSince1970)).jpeg"
            let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.avatars)
                .upload(
                    path: "\(userId.uuidString.lowercased())/\(fileName)",
                    file: file
                )

            return .success(fileName)
        } catch {
            return .failure(error)
        }
    }

    func deleteCurrentAccount() async -> Result<Void, Error> {
        do {
            try await client
                .database
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
                .database
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

    func getTimePeriodStatistics(userId: UUID, timePeriod: TimePeriodStatistic.TimePeriod) async
    -> Result<TimePeriodStatistic, Error> {
        do {
            let result: TimePeriodStatistic = try await client
                .database
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
}
