import Foundation
import Models
internal import Supabase

struct SupabaseProductRepository: ProductRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func search(searchTerm: String, filter: Product.Filter?) async throws -> [Product.Joined] {
        let queryBuilder = try client
            .rpc(
                fn: .searchProducts,
                params: Product.SearchParams(searchTerm: searchTerm, filter: filter)
            )
            .select(Product.getQuery(.joinedBrandSubcategoriesRatings(false)))

        if let filter, let sortBy = filter.sortBy {
            return try await queryBuilder
                .order("average_rating", ascending: sortBy == .highestRated ? false : true)
                .execute()
                .value
        } else {
            return try await queryBuilder
                .execute()
                .value
        }
    }

    func getFeed(_ type: Product.FeedType, from: Int, to: Int, categoryFilterId: Models.Category.Id?) async throws -> [Product.Joined] {
        var queryBuilder = client
            .from(.viewProductRatings)
            .select(Product.getQuery(.joinedBrandSubcategoriesRatings(false)))

        if let categoryFilterId {
            queryBuilder = queryBuilder.eq("category_id", value: categoryFilterId.rawValue)
        }

        switch type {
        case .topRated:
            return try await queryBuilder
                .range(from: from, to: to)
                .order("average_rating", ascending: false)
                .execute()
                .value
        case .trending:
            return try await queryBuilder
                .range(from: from, to: to)
                .order("check_ins_during_previous_month", ascending: false)
                .execute()
                .value
        case .latest:
            return try await queryBuilder
                .range(from: from, to: to)
                .order("created_at", ascending: false)
                .execute()
                .value
        }
    }

    func getUnverified() async throws -> [Product.Joined] {
        try await client
            .from(.products)
            .select(Product.getQuery(.joinedBrandSubcategoriesCreator(false)))
            .eq("is_verified", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func search(barcode: Barcode) async throws -> [Product.Joined] {
        let response: [Product.Barcode.Joined] = try await client
            .from(.productBarcodes)
            .select(Product.Barcode.getQuery(.joined(false)))
            .eq("barcode", value: barcode.barcode)
            .execute()
            .value

        return response.map(\.product)
    }

    func getById(id: Product.Id) async throws -> Product.Joined {
        try await client
            .from(.products)
            .select(Product.getQuery(.joinedBrandSubcategories(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Product.Id) async throws -> Product.Detailed {
        try await client
            .from(.products)
            .select(Product.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getAll() async throws -> [Product.Joined] {
        try await client
            .from(.products)
            .select(Product.getQuery(.joinedBrandSubcategories(false)))
            .execute()
            .value
    }

    func checkIfOnWishlist(id: Product.Id) async throws -> Bool {
        try await client
            .rpc(
                fn: .isOnCurrentUserWishlist,
                params: ProfileWishlist.CheckIfOnWishlist(id: id)
            )
            .single()
            .execute()
            .value
    }

    func addToWishlist(productId: Product.Id) async throws {
        try await client
            .from(.profileWishlistItems)
            .insert(ProfileWishlist.New(productId: productId.rawValue))
            .single()
            .execute()
    }

    func removeFromWishlist(productId: Product.Id) async throws {
        try await client
            .from(.profileWishlistItems)
            .delete()
            .eq("product_id", value: productId.rawValue)
            .execute()
    }

    func getWishlistItems(profileId: Profile.Id) async throws -> [ProfileWishlist.Joined] {
        try await client
            .from(.profileWishlistItems)
            .select(ProfileWishlist.getQuery(.joined(false)))
            .eq("created_by", value: profileId.uuidString)
            .execute()
            .value
    }

    func getByProfile(id: Profile.Id) async throws -> [Product.Joined] {
        try await client
            .from(.viewProfileProductRatings)
            .select(Product.getQuery(.joinedBrandSubcategoriesProfileRatings(false)))
            .eq("check_in_created_by", value: id.uuidString)
            .execute()
            .value
    }

    func getCreatedByUserId(id: Profile.Id) async throws -> [Product.Joined] {
        try await client
            .from(.products)
            .select(Product.getQuery(.joinedBrandSubcategories(false)))
            .eq("created_by", value: id.uuidString)
            .execute()
            .value
    }

    func uploadLogo(productId: Product.Id, data: Data) async throws -> ImageEntity {
        let fileName = "\(productId)_\(Date.now.timeIntervalSince1970).jpeg"

        try await client
            .storage
            .from(.productLogos)
            .upload(path: fileName, file: data, options: .init(contentType: "image/jpeg"))

        return try await imageEntityRepository.getByFileName(from: .productLogos, fileName: fileName)
    }

    func delete(id: Product.Id) async throws {
        try await client
            .from(.products)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func create(newProductParams: Product.NewRequest) async throws -> Product.Joined {
        try await client
            .rpc(fn: .createProduct, params: newProductParams)
            .select(Product.getQuery(.joinedBrandSubcategories(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func mergeProducts(productId: Product.Id, toProductId: Product.Id) async throws {
        try await client
            .rpc(
                fn: .mergeProducts,
                params: Product.MergeProductsParams(productId: productId, toProductId: toProductId)
            )
            .execute()
    }

    func markAsDuplicate(productId: Product.Id, duplicateOfProductId: Product.Id) async throws {
        try await client
            .from(.productEditSuggestions)
            .insert(Product.DuplicateRequest(productId: productId, duplicateOfProductId: duplicateOfProductId),
                    returning: .none)
            .execute()
            .value
    }

    func createUpdateSuggestion(productEditSuggestionParams: Product.EditSuggestionRequest) async throws {
        try await client
            .from(.productEditSuggestions)
            .insert(productEditSuggestionParams,
                    returning: .none)
            .execute()
            .value
    }

    func editProduct(productEditParams: Product.EditRequest) async throws -> Product.Joined {
        try await client
            .rpc(fn: .editProduct, params: productEditParams)
            .select(Product.getQuery(.joinedBrandSubcategories(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func verification(id: Product.Id, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifyProduct, params: Product.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }

    func getSummaryById(id: Product.Id) async throws -> Summary {
        try await client
            .rpc(fn: .getProductSummary, params: Product.SummaryRequest(id: id))
            .select()
            .limit(1)
            .single()
            .execute()
            .value
    }

    func resolveEditSuggestion(editSuggestion: Product.EditSuggestion) async throws {
        try await client
            .from(.productEditSuggestions)
            .update(["resolved_at": Date.now])
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func deleteEditSuggestion(editSuggestion: Product.EditSuggestion) async throws {
        try await client
            .from(.productEditSuggestions)
            .delete()
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func getEditSuggestions() async throws -> [Product.EditSuggestion] {
        try await client
            .from(.productEditSuggestions)
            .select(Product.EditSuggestion.getQuery(.joined(false)))
            .execute()
            .value
    }
}
