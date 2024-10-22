import Foundation
import Logging
internal import Supabase

@Observable
public final class Repository: RepositoryProtocol {
    public let admin: AdminRepository
    public let appConfig: AppConfigRepository
    public let profile: ProfileRepository
    public let role: RoleRepository
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
    public let subscription: SubscriptionRepository
    public let imageEntity: ImageEntityRepository

    public init(apiUrl: URL, apiKey: String, headers: [String: String]) {
        let client = SupabaseClient(
            supabaseURL: apiUrl,
            supabaseKey: apiKey,
            options: .init(auth: .init(flowType: .implicit), global: .init(headers: headers, logger: CustomSupabaseLogger()))
        )

        let cache = CacheClient()

        admin = SupabaseAdminRepository(client: client)
        appConfig = SupabaseAppConfigRepository(client: client)
        imageEntity = SupabaseImageEntityRepository(client: client, cache: cache)
        profile = SupabaseProfileRepository(client: client, imageEntityRepository: imageEntity)
        role = SupabaseRoleRepository(client: client)
        checkIn = SupabaseCheckInRepository(client: client, imageEntityRepository: imageEntity)
        checkInComment = SupabaseCheckInCommentRepository(client: client)
        checkInReactions = SupabaseCheckInReactionsRepository(client: client)
        product = SupabaseProductRepository(client: client, imageEntityRepository: imageEntity)
        productBarcode = SupabaseProductBarcodeRepository(client: client)
        auth = SupabaseAuthRepository(client: client)
        company = SupabaseCompanyRepository(client: client, imageEntityRepository: imageEntity)
        friend = SupabaseFriendsRepository(client: client)
        category = SupabaseCategoryRepository(client: client)
        subcategory = SupabaseSubcategoryRepository(client: client)
        servingStyle = SupabaseServingStyleRepository(client: client)
        brand = SupabaseBrandRepository(client: client, imageEntityRepository: imageEntity)
        subBrand = SupabaseSubBrandRepository(client: client)
        flavor = SupabaseFlavorRepository(client: client)
        notification = SupabaseNotificationRepository(client: client)
        location = SupabaseLocationRepository(client: client)
        document = SupabaseDocumentRepository(client: client)
        report = SupabaseReportRepository(client: client)
        subscription = SupabaseSubscriptionRepository(client: client)
    }
}

struct CustomSupabaseLogger: SupabaseLogger {
    let logger = Logger(label: "SupabaseLogger")

    func log(message: SupabaseLogMessage) {
        switch message.level {
        case .verbose:
            logger.log(level: .info, "\(message.description)")
        case .debug:
            logger.log(level: .debug, "\(message.description)")
        case .warning, .error:
            logger.log(level: .error, "\(message.description)")
        }
    }
}
