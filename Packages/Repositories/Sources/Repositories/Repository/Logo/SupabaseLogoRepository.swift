import Models
internal import Supabase
import Foundation

struct SupabaseLogoRepository: LogoRepository {
    let client: SupabaseClient

    func insert(data: Data, width: Int, height: Int, blurHash: String, label: String) async throws -> Logo.Saved {
        let fileName = "\(UUID().uuidString.lowercased()).jpeg"
        let metadata = try? ["width": AnyJSON(width), "height": AnyJSON(height), "blur_hash": AnyJSON(blurHash), "label": AnyJSON(label)]
        try await client
            .storage
            .from(.logos)
            .upload(
                fileName,
                data: data,
                options: .init(cacheControl: "max-age=3600", contentType: "image/jpeg", metadata: metadata)
            )

        return try await getByFileName(fileName: fileName)
    }

    func update(id: Logo.Id, label: String) async throws -> Logo.Saved {
        try await client
            .from(.logos)
            .update(["label": label])
            .eq("id", value: id.rawValue)
            .select(Logo.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Logo.Id) async throws {
        try await client
            .from(.logos)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func getAll() async throws -> [Logo.Saved] {
        try await client
            .from(.logos)
            .select(Logo.getQuery(.saved(false)))
            .order("label")
            .execute()
            .value
    }

    func getByFileName(fileName: String) async throws -> Logo.Saved {
        try await client
            .from(.logos)
            .select(Logo.getQuery(.saved(false)))
            .eq("file", value: fileName)
            .limit(1)
            .single()
            .execute()
            .value
    }
}
