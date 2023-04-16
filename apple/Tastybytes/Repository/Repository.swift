import Supabase
import SwiftUI

protocol RepositoryProtocol {
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
  var servingStyle: ServingStyleRepository { get }
  var brand: BrandRepository { get }
  var subBrand: SubBrandRepository { get }
  var flavor: FlavorRepository { get }
  var notification: NotificationRepository { get }
  var location: LocationRepository { get }
  var document: DocumentRepository { get }
  var report: ReportRepository { get }
}

final class Repository: RepositoryProtocol, ObservableObject {
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
  let servingStyle: ServingStyleRepository
  let brand: BrandRepository
  let subBrand: SubBrandRepository
  let flavor: FlavorRepository
  let notification: NotificationRepository
  let location: LocationRepository
  let document: DocumentRepository
  let report: ReportRepository

  init(supabaseClient: SupabaseClient) {
    profile = SupabaseProfileRepository(client: supabaseClient)
    checkIn = SupabaseCheckInRepository(client: supabaseClient)
    checkInComment = SupabaseCheckInCommentRepository(client: supabaseClient)
    checkInReactions = SupabaseCheckInReactionsRepository(client: supabaseClient)
    product = SupabaseProductRepository(client: supabaseClient)
    productBarcode = SupabaseProductBarcodeRepository(client: supabaseClient)
    auth = SupabaseAuthRepository(client: supabaseClient)
    company = SupabaseCompanyRepository(client: supabaseClient)
    friend = SupabaseFriendsRepository(client: supabaseClient)
    category = SupabaseCategoryRepository(client: supabaseClient)
    subcategory = SupabaseSubcategoryRepository(client: supabaseClient)
    servingStyle = SupabaseServingStyleRepository(client: supabaseClient)
    brand = SupabaseBrandRepository(client: supabaseClient)
    subBrand = SupabaseSubBrandRepository(client: supabaseClient)
    flavor = SupabaseFlavorRepository(client: supabaseClient)
    notification = SupabaseNotificationRepository(client: supabaseClient)
    location = SupabaseLocationRepository(client: supabaseClient)
    document = SupabaseDocumentRepository(client: supabaseClient)
    report = SupabaseReportRepository(client: supabaseClient)
  }
}
