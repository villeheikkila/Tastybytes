import Supabase
import SwiftUI

protocol Client {
  var profile: ProfileRepository { get }
  var checkIn: CheckInRepository { get }
  var checkInComment: CheckInCommentRepository { get }
  var checkInReactions: CheckInReactionsRepository { get }
  var product: ProductRepository { get }
  var productBarcode: ProductBarcodeRepository { get }
  var auth: AuthRepository { get }
  var company: CompanyRepository { get }
  var friend: FriendRepository { get }
  var category: CategoryRepository { get }
  var subcategory: SubcategoryRepository { get }
  var brand: BrandRepository { get }
  var subBrand: SubBrandRepository { get }
  var flavor: FlavorRepository { get }
  var notification: NotificationRepository { get }
  var location: LocationRepository { get }
  var document: DocumentRepository { get }
}

class AppClient: Client {
  let supabase: SupabaseClient

  let profile: ProfileRepository
  let checkIn: CheckInRepository
  let checkInComment: CheckInCommentRepository
  let checkInReactions: CheckInReactionsRepository
  let product: ProductRepository
  let productBarcode: ProductBarcodeRepository
  let auth: AuthRepository
  let company: CompanyRepository
  let friend: FriendRepository
  let category: CategoryRepository
  let subcategory: SubcategoryRepository
  let brand: BrandRepository
  let subBrand: SubBrandRepository
  let flavor: FlavorRepository
  let notification: NotificationRepository
  let location: LocationRepository
  let document: DocumentRepository

  init(url: URL, apiKey: String) {
    let client = SupabaseClient(
      supabaseURL: url,
      supabaseKey: apiKey
    )
    supabase = client
    profile = SupabaseProfileRepository(client: client)
    checkIn = SupabaseCheckInRepository(client: client)
    checkInComment = SupabaseCheckInCommentRepository(client: client)
    checkInReactions = SupabaseCheckInReactionsRepository(client: client)
    product = SupabaseProductRepository(client: client)
    productBarcode = SupabaseProductBarcodeRepository(client: client)
    auth = SupabaseAuthRepository(client: client)
    company = SupabaseCompanyRepository(client: client)
    friend = SupabaseFriendsRepository(client: client)
    category = SupabaseCategoryRepository(client: client)
    subcategory = SupabaseSubcategoryRepository(client: client)
    brand = SupabaseBrandRepository(client: client)
    subBrand = SupabaseSubBrandRepository(client: client)
    flavor = SupabaseFlavorRepository(client: client)
    notification = SupabaseNotificationRepository(client: client)
    location = SupabaseLocationRepository(client: client)
    document = SupabaseDocumentRepository(client: client)
  }
}
