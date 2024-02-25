import Foundation
import Models
import Supabase

struct SupabaseProductRepository: ProductRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func search(searchTerm: String, filter: Product.Filter?) async -> Result<[Product.Joined], Error> {
        do {
            let queryBuilder = try await client
                .database
                .rpc(
                    fn: .searchProducts,
                    params: Product.SearchParams(searchTerm: searchTerm, filter: filter)
                )
                .select(Product.getQuery(.joinedBrandSubcategoriesRatings(false)))

            if let filter, let sortBy = filter.sortBy {
                let response: [Product.Joined] = try await queryBuilder
                    .order("average_rating", ascending: sortBy == .highestRated ? false : true)
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
        var queryBuilder = await client
            .database
            .from(.viewProductRatings)
            .select(Product.getQuery(.joinedBrandSubcategoriesRatings(false)))

        if let categoryFilterId {
            queryBuilder = queryBuilder.eq("category_id", value: categoryFilterId)
        }

        do {
            switch type {
            case .topRated:
                let response: [Product.Joined] = try await queryBuilder
                    .range(from: from, to: to)
                    .order("average_rating", ascending: false)
                    .execute()
                    .value
                return .success(response)
            case .trending:
                let response: [Product.Joined] = try await queryBuilder
                    .range(from: from, to: to)
                    .order("check_ins_during_previous_month", ascending: false)
                    .execute()
                    .value
                return .success(response)
            case .latest:
                let response: [Product.Joined] = try await queryBuilder
                    .range(from: from, to: to)
                    .order("created_at", ascending: false)
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
                .from(.products)
                .select(Product.getQuery(.joinedBrandSubcategoriesCreator(false)))
                .eq("is_verified", value: false)
                .order("created_at", ascending: false)
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
                .from(.productBarcodes)
                .select(ProductBarcode.getQuery(.joined(false)))
                .eq("barcode", value: barcode.barcode)
                .eq("type", value: barcode.type)
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
                .from(.products)
                .select(Product.getQuery(.joinedBrandSubcategories(false)))
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
                .from(.profileWishlistItems)
                .insert(ProfileWishlist.New(productId: productId))
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
                .from(.profileWishlistItems)
                .delete()
                .eq("product_id", value: productId)
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
                .from(.profileWishlistItems)
                .select(ProfileWishlist.getQuery(.joined(false)))
                .eq("created_by", value: profileId.uuidString)
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
                .from(.viewProfileProductRatings)
                .select(Product.getQuery(.joinedBrandSubcategoriesProfileRatings(false)))
                .eq("check_in_created_by", value: id.uuidString)
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
                .from(.products)
                .select(Product.getQuery(.joinedBrandSubcategories(false)))
                .eq("created_by", value: id.uuidString)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadLogo(productId: Int, data: Data) async -> Result<ImageEntity, Error> {
        do {
            let fileName = "\(productId)_\(Date.now.timeIntervalSince1970).jpeg"
            let fileOptions = FileOptions(cacheControl: "604800", contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.productLogos)
                .upload(path: fileName, file: data, options: fileOptions)

            return await imageEntityRepository.getByFileName(from: .productLogos, fileName: fileName)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.products)
                .delete()
                .eq("id", value: id)
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
                .select("id")
                .limit(1)
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
                .from(.productDuplicateSuggestions)
                .insert(Product.DuplicateRequest(productId: productId, duplicateOfProductId: duplicateOfProductId),
                        returning: .none)
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
                .from(.productEditSuggestions)
                .insert(productEditSuggestionParams,
                        returning: .none)
                .execute()
                .value

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func editProduct(productEditParams: Product.EditRequest) async -> Result<Product.Joined, Error> {
        do {
            let updateResult: Product.Joined = try await client
                .database
                .rpc(fn: .editProduct, params: productEditParams)
                .select(Product.getQuery(.joinedBrandSubcategories(false)))
                .limit(1)
                .single()
                .execute()
                .value

            // TODO: Fix this when it is possible
            switch await getById(id: updateResult.id) {
            case let .success(product):
                return .success(product)
            case let .failure(error):
                return .failure(error)
            }
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
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
