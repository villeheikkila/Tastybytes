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

    func getFeed(_ type: Product.FeedType, page: Int, pageSize: Int, categoryFilterId _: Models.Category.Id?) async throws -> [Product.Joined] {
        struct PaginationParams: Encodable {
            let pageNumber: Int
            let pageSize: Int
            let sortBy: SortOption

            enum SortOption: String, Codable {
                case averageRating = "average_rating"
                case checkInsDuringPreviousMonth = "check_ins_during_previous_month"
                case createdAt = "created_at"
            }

            enum CodingKeys: String, CodingKey {
                case pageNumber = "p_page_number"
                case pageSize = "p_page_size"
                case sortBy = "p_sort_by"
            }

            init(pageNumber: Int, pageSize: Int, type: Product.FeedType) {
                self.pageNumber = pageNumber
                self.pageSize = pageSize
                sortBy = switch type {
                case .latest:
                    .createdAt
                case .topRated:
                    .averageRating
                case .trending:
                    .checkInsDuringPreviousMonth
                }
            }
        }

        return try await client
            .rpc(
                fn: .getPaginatedProductRatings,
                params: PaginationParams(pageNumber: page, pageSize: pageSize, type: type)
            )
            .select(Product.getQuery(.joinedBrandSubcategoriesRatings(false)))
            .execute()
            .value
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
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func checkIfOnWishlist(id: Product.Id) async throws -> Bool {
        try await client
            .rpc(
                fn: .isOnCurrentUserWishlist,
                params: ["p_product_id": id.rawValue]
            )
            .single()
            .execute()
            .value
    }

    func addToWishlist(productId: Product.Id) async throws {
        try await client
            .from(.profileWishlistItems)
            .insert(["product_id": productId.rawValue])
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

    func getWishlistItems(profileId: Profile.Id) async throws -> [Profile.Wishlist.Joined] {
        try await client
            .from(.profileWishlistItems)
            .select(Profile.Wishlist.getQuery(.joined(false)))
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

    func mergeProducts(id: Product.Id, toProductId: Product.Id) async throws {
        try await client
            .rpc(
                fn: .mergeProducts,
                params: Product.MergeProductsParams(productId: id, toProductId: toProductId)
            )
            .execute()
    }

    func markAsDuplicate(id: Product.Id, duplicateOfProductId: Product.Id) async throws {
        try await client
            .from(.productEditSuggestions)
            .insert(["product_id": id.rawValue, "duplicate_of_product_id": duplicateOfProductId.rawValue],
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
            .rpc(fn: .getProductSummary, params: ["p_product_id": id.rawValue])
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
    
    func addLogo(id: Product.Id, logoId: Logo.Id) async throws {
        try await client
            .from(.productsLogos)
            .insert(["product_id": AnyJSON(id), "logo_id": AnyJSON(logoId)])
            .execute()
            .value
    }
    
    func removeLogo(id: Product.Id, logoId: Logo.Id) async throws {
        try await client
            .from(.productsLogos)
            .delete()
            .eq("product_id", value: id.rawValue)
            .eq("logo_id", value: logoId.rawValue)
            .execute()
            .value
    }
}
