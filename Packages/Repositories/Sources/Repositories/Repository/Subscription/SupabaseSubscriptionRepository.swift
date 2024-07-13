import Foundation
import Models
internal import Supabase

struct SupabaseSubscriptionRepository: SubscriptionRepository {
    let client: SupabaseClient

    func getActiveGroup() async throws -> SubscriptionGroup.Joined {
        try await client
            .from(.subscriptionGroups)
            .select(SubscriptionGroup.getQuery(.joined(false)))
            .eq("is_active", value: true)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func syncSubscriptionTransaction(transactionInfo: SubscriptionTransaction) async throws {
        try await client
            .from(.subscriptionTransactions)
            .upsert(transactionInfo, onConflict: "id")
            .execute()
            .value
    }
}
