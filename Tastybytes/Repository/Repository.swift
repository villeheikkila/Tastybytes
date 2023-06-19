import Observation
import PostgREST
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

@Observable
final class Repository: RepositoryProtocol {
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

extension PostgrestClient {
    enum SupabaseFunctions {
        case verifySubcategory
        case getActivityFeed
        case createCheckIn
        case updateCheckIn
        case deleteCheckInAsModerator
        case getProfileSummary

        var fn: String {
            switch self {
            case .verifySubcategory:
                "fnc__verify_subcategory"
            case .getActivityFeed:
                "fnc__get_activity_feed"
            case .createCheckIn:
                "fnc__create_check_in"
            case .updateCheckIn:
                "fnc__update_check_in"
            case .deleteCheckInAsModerator:
                "fnc__delete_check_in_as_moderator"
            case .getProfileSummary:
                "fnc__get_profile_summary"
            }
        }
    }

    func rpc(
        function: SupabaseFunctions,
        params: some Encodable,
        count: CountOption? = nil
    ) -> PostgrestTransformBuilder {
        rpc(fn: function.fn, params: params, count: count)
    }

    func rpc(
        function: SupabaseFunctions,
        count: CountOption? = nil
    ) -> PostgrestTransformBuilder {
        rpc(fn: function.fn, count: count)
    }
}
