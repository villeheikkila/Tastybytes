import Supabase
import SwiftUI

public protocol RepositoryProtocol: Sendable {
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

public struct Repository: RepositoryProtocol {
    public let profile: ProfileRepository
    public let checkIn: CheckInRepository
    public let checkInComment: CheckInCommentRepository
    public let checkInReactions: CheckInReactionsRepository
    public let product: ProductRepository
    public let productBarcode: ProductBarcodeRepository
    public let auth: AuthRepository
    public let company: CompanyRepository
    public let friend: FriendRepository
    public let category: CategoryRepository
    public let subcategory: SubcategoryRepository
    public let servingStyle: ServingStyleRepository
    public let brand: BrandRepository
    public let subBrand: SubBrandRepository
    public let flavor: FlavorRepository
    public let notification: NotificationRepository
    public let location: LocationRepository
    public let document: DocumentRepository
    public let report: ReportRepository

    public init(supabaseURL: URL, supabaseKey: String, headers: [String: String]) {
        let client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: .init(auth: .init(flowType: .implicit), global: .init(headers: headers))
        )
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
        servingStyle = SupabaseServingStyleRepository(client: client)
        brand = SupabaseBrandRepository(client: client)
        subBrand = SupabaseSubBrandRepository(client: client)
        flavor = SupabaseFlavorRepository(client: client)
        notification = SupabaseNotificationRepository(client: client)
        location = SupabaseLocationRepository(client: client)
        document = SupabaseDocumentRepository(client: client)
        report = SupabaseReportRepository(client: client)
    }
}
