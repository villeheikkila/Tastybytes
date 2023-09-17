import Supabase

public protocol RepositoryProtocol {
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

    public init(supabaseClient: SupabaseClient) {
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
