import Foundation
import Models
import Supabase
import SupabaseStorage

struct SupabaseProductRepository: ProductRepository {
    let client: SupabaseClient

    public func search(searchTerm: String, filter: Product.Filter?) async -> Result<[Product.Joined], Error> {
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

    public func getFeed(_ type: Product.FeedType, from: Int, to: Int,
                        categoryFilterId: Int?) async -> Result<[Product.Joined], Error>
    {
        var queryBuilder = client
            .database
            .from(.viewProductRatings)
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
            print(error)
            return .failure(error)
        }
    }

    public func getUnverified() async -> Result<[Product.Joined], Error> {
        do {
            let response: [Product.Joined] = try await client
                .database
                .from(.products)
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

    public func search(barcode: Barcode) async -> Result<[Product.Joined], Error> {
        do {
            let response: [ProductBarcode.Joined] = try await client
                .database
                .from(.productBarcodes)
                .select(columns: ProductBarcode.getQuery(.joined(false)))
                .eq(column: "barcode", value: barcode.barcode)
                .eq(column: "type", value: barcode.type)
                .execute()
                .value

            return .success(response.map(\.product))
        } catch {
            return .failure(error)
        }
    }

    public func getById(id: Int) async -> Result<Product.Joined, Error> {
        do {
            let response: Product.Joined = try await client
                .database
                .from(.products)
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

    public func checkIfOnWishlist(id: Int) async -> Result<Bool, Error> {
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

    public func addToWishlist(productId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.profileWishlistItems)
                .insert(values: ProfileWishlist.New(productId: productId))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func removeFromWishlist(productId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.profileWishlistItems)
                .delete()
                .eq(column: "product_id", value: productId)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func getWishlistItems(profileId: UUID) async -> Result<[ProfileWishlist.Joined], Error> {
        do {
            let reponse: [ProfileWishlist.Joined] = try await client
                .database
                .from(.profileWishlistItems)
                .select(columns: ProfileWishlist.getQuery(.joined(false)))
                .eq(column: "created_by", value: profileId.uuidString)
                .execute()
                .value

            return .success(reponse)
        } catch {
            return .failure(error)
        }
    }

    public func getByProfile(id: UUID) async -> Result<[Product.Joined], Error> {
        do {
            let response: [Product.Joined] = try await client
                .database
                .from(.viewProfileProductRatings)
                .select(columns: Product.getQuery(.joinedBrandSubcategoriesProfileRatings(false)))
                .eq(column: "check_in_created_by", value: id.uuidString)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func getCreatedByUserId(id: UUID) async -> Result<[Product.Joined], Error> {
        do {
            let response: [Product.Joined] = try await client
                .database
                .from(.products)
                .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
                .eq(column: "created_by", value: id.uuidString)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func uploadLogo(productId: Int, data: Data) async -> Result<String, Error> {
        do {
            let fileName = "\(productId)_\(Date().customFormat(.fileNameSuffix)).jpeg"
            let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.logos)
                .upload(path: fileName, file: file, fileOptions: nil)

            return .success(fileName)
        } catch {
            return .failure(error)
        }
    }

    public func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.products)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error> {
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

    public func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error> {
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

    public func markAsDuplicate(productId: Int, duplicateOfProductId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.productDuplicateSuggestions)
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

    public func createUpdateSuggestion(productEditSuggestionParams: Product
        .EditSuggestionRequest) async -> Result<Void, Error>
    {
        do {
            try await client
                .database
                .from(.productEditSuggestions)
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

    public func editProduct(productEditParams: Product.EditRequest) async -> Result<Void, Error> {
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

    public func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
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

    public func getSummaryById(id: Int) async -> Result<Summary, Error> {
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
