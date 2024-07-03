import Foundation
import Models
internal import Supabase

struct SupabaseSubscriptionRepository: SubscriptionRepository {
    let client: SupabaseClient

    func getActiveGroup() async -> Result<SubscriptionGroup.Joined, Error> {
        do {
            let response: SubscriptionGroup.Joined = try await client
                .from(.subscriptionGroups)
                .select(SubscriptionGroup.getQuery(.joined(false)))
                .eq("is_active", value: true)
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func syncSubscriptionTransaction(transactionInfo: SubscriptionTransaction) async -> Result<Void, Error> {
        do {
            try await client
                .from(.subscriptionTransactions)
                .upsert(transactionInfo, onConflict: "id")
                .execute()
                .value

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
