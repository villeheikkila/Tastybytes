import Foundation
import Supabase
import SupabaseStorage

protocol ProductRepository {
    func search(searchTerm: String, filter: Product.Filter?) async -> Result<[Product.Joined], Error>
    func search(barcode: Barcode) async -> Result<[Product.Joined], Error>
    func getById(id: Int) async -> Result<Product.Joined, Error>
    func getByProfile(id: UUID) async -> Result<[Product.Joined], Error>
    func getFeed(_ type: Product.FeedType, from: Int, to: Int, categoryFilterId: Int?) async
        -> Result<[Product.Joined], Error>
    func delete(id: Int) async -> Result<Void, Error>
    func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error>
    func getUnverified() async -> Result<[Product.Joined], Error>
    // func getDuplicateSuggestions() async -> Result<[ProductDuplicateSuggestion.Joined], Error>
    func checkIfOnWishlist(id: Int) async -> Result<Bool, Error>
    func removeFromWishlist(productId: Int) async -> Result<Void, Error>
    func getWishlistItems(profileId: UUID) async -> Result<[ProfileWishlist.Joined], Error>
    func addToWishlist(productId: Int) async -> Result<Void, Error>
    func uploadLogo(productId: Int, data: Data) async -> Result<String, Error>
    func getSummaryById(id: Int) async -> Result<Summary, Error>
    func getCreatedByUserId(id: UUID) async -> Result<[Product.Joined], Error>
    func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error>
    func markAsDuplicate(productId: Int, duplicateOfProductId: Int) async -> Result<Void, Error>
    func editProduct(productEditParams: Product.EditRequest) async -> Result<Void, Error>
    func createUpdateSuggestion(productEditSuggestionParams: Product.EditSuggestionRequest) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
}

struct SupabaseProductRepository: ProductRepository {
    let client: SupabaseClient

    func search(searchTerm: String, filter: Product.Filter?) async -> Result<[Product.Joined], Error> {
        let queryBuilder = client
            .database
            .rpc(
                fn: .searchProducts,
                params: Product.SearchParams(searchTerm: searchTerm, filter: filter)
            )
            .select(columns: Product.getQuery(.joinedBrandSubcategoriesRatings(false)))

        do {
            if let filter, let sortBy = filter.sortBy {
                let response: [Product.Joined] = try await queryBuilder
                    .order(column: "average_rating", ascending: sortBy == .highestRated ? false : true)
                    .execute()
                    .value
                return .success(response)

            } else {
                let response: [Product.Joined] = try await queryBuilder
                    .execute()
                    .value
                return .success(response)
            }

        } catch {
            return .failure(error)
        }
    }

    func getFeed(_ type: Product.FeedType, from: Int, to: Int,
                 categoryFilterId: Int?) async -> Result<[Product.Joined], Error>
    {
        var queryBuilder = client
            .database
            .from("view__product_ratings")
            .select(columns: Product.getQuery(.joinedBrandSubcategoriesRatings(false)))

        if let categoryFilterId {
            queryBuilder = queryBuilder.eq(column: "category_id", value: categoryFilterId)
        }

        do {
            switch type {
            case .topRated:
                let response: [Product.Joined] = try await queryBuilder
                    .range(from: from, to: to)
                    .order(column: "average_rating", ascending: false)
                    .execute()
                    .value
                return .success(response)
            case .trending:
                let response: [Product.Joined] = try await queryBuilder
                    .range(from: from, to: to)
                    .order(column: "check_ins_during_previous_month", ascending: false)
                    .execute()
                    .value
                return .success(response)
            case .latest:
                let response: [Product.Joined] = try await queryBuilder
                    .range(from: from, to: to)
                    .order(column: "created_at", ascending: false)
                    .execute()
                    .value
                return .success(response)
            }
        } catch {
            return .failure(error)
        }
    }

    func getUnverified() async -> Result<[Product.Joined], Error> {
        do {
            let response: [Product.Joined] = try await client
                .database
                .from(Product.getQuery(.tableName))
                .select(columns: Product.getQuery(.joinedBrandSubcategoriesCreator(false)))
                .eq(column: "is_verified", value: false)
                .order(column: "created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func search(barcode: Barcode) async -> Result<[Product.Joined], Error> {
        do {
            let response: [ProductBarcode.Joined] = try await client
                .database
                .from(ProductBarcode.getQuery(.tableName))
                .select(columns: ProductBarcode.getQuery(.joined(false)))
                .eq(column: "barcode", value: barcode.barcode)
                .eq(column: "type", value: barcode.type.rawValue)
                .execute()
                .value

            return .success(response.map(\.product))
        } catch {
            return .failure(error)
        }
    }

    func getById(id: Int) async -> Result<Product.Joined, Error> {
        do {
            let response: Product.Joined = try await client
                .database
                .from(Product.getQuery(.tableName))
                .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func checkIfOnWishlist(id: Int) async -> Result<Bool, Error> {
        do {
            let response: Bool = try await client
                .database
                .rpc(
                    fn: .isOnCurrentUserWishlist,
                    params: ProfileWishlist.CheckIfOnWishlist(id: id)
                )
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func addToWishlist(productId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(ProfileWishlist.getQuery(.tableName))
                .insert(values: ProfileWishlist.New(productId: productId))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func removeFromWishlist(productId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(ProfileWishlist.getQuery(.tableName))
                .delete()
                .eq(column: "product_id", value: productId)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func getWishlistItems(profileId: UUID) async -> Result<[ProfileWishlist.Joined], Error> {
        do {
            let reponse: [ProfileWishlist.Joined] = try await client
                .database
                .from(ProfileWishlist.getQuery(.tableName))
                .select(columns: ProfileWishlist.getQuery(.joined(false)))
                .eq(column: "created_by", value: profileId.uuidString)
                .execute()
                .value

            return .success(reponse)
        } catch {
            return .failure(error)
        }
    }

    func getByProfile(id: UUID) async -> Result<[Product.Joined], Error> {
        do {
            let response: [Product.Joined] = try await client
                .database
                .from("view__profile_product_ratings")
                .select(columns: Product.getQuery(.joinedBrandSubcategoriesProfileRatings(false)))
                .eq(column: "check_in_created_by", value: id.uuidString)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getCreatedByUserId(id: UUID) async -> Result<[Product.Joined], Error> {
        do {
            let response: [Product.Joined] = try await client
                .database
                .from(Product.getQuery(.tableName))
                .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
                .eq(column: "created_by", value: id.uuidString)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByUserId(userId: Int) async -> Result<Product.Joined, Error> {
        do {
            let response: Product.Joined = try await client
                .database
                .from("product_user_ratings")
                .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
                .eq(column: "id", value: userId)
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadLogo(productId: Int, data: Data) async -> Result<String, Error> {
        do {
            let fileName = "\(productId)_\(Date().customFormat(.fileNameSuffix)).jpeg"
            let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(id: Product.getQuery(.logoBucket))
                .upload(path: fileName, file: file, fileOptions: nil)

            return .success(fileName)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(Product.getQuery(.tableName))
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error> {
        do {
            let product: IntId = try await client
                .database
                .rpc(fn: .createProduct, params: newProductParams)
                .select(columns: "id")
                .limit(count: 1)
                .single()
                .execute()
                .value
            /**
             Load joined object after product has been created so joins work correctly for new rows created
             during the create_product transaction
             */
            switch await getById(id: product.id) {
            case let .success(response):
                return .success(response)
            case let .failure(error):
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }

    func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(
                    fn: .mergeProducts,
                    params: Product.MergeProductsParams(productId: productId, toProductId: toProductId)
                )
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func markAsDuplicate(productId: Int, duplicateOfProductId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(ProductDuplicateSuggestion.getQuery(.tableName))
                .insert(
                    values: Product.DuplicateRequest(productId: productId, duplicateOfProductId: duplicateOfProductId),
                    returning: .none
                )
                .execute()
                .value

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func createUpdateSuggestion(productEditSuggestionParams: Product
        .EditSuggestionRequest) async -> Result<Void, Error>
    {
        do {
            try await client
                .database
                .from("product_edit_suggestions")
                .insert(
                    values: productEditSuggestionParams,
                    returning: .none
                )
                .execute()
                .value

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func editProduct(productEditParams: Product.EditRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .editProduct, params: productEditParams)
                .execute()
                .value

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .verifyProduct, params: Product.VerifyRequest(id: id, isVerified: isVerified))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func getSummaryById(id: Int) async -> Result<Summary, Error> {
        do {
            let response: Summary = try await client
                .database
                .rpc(fn: .getProductSummary, params: Product.SummaryRequest(id: id))
                .select()
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
