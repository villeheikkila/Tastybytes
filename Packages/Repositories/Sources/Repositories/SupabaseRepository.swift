import Foundation
import OSLog
import Supabase

@Observable
public final class Repository: RepositoryProtocol {
    public let appConfig: AppConfigRepository
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
    public let subscription: SubscriptionRepository
    public let imageEntity: ImageEntityRepository

    public init(supabaseURL: URL, supabaseKey: String, headers: [String: String]) {
        let client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: .init(auth: .init(flowType: .implicit), global: .init(headers: headers, logger: CustomSupabaseLogger()))
        )
        appConfig = SupabaseAppConfigRepository(client: client)
        imageEntity = SupabaseImageEntityRepository(client: client)
        profile = SupabaseProfileRepository(client: client, imageEntityRepository: imageEntity)
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

final class CustomSupabaseLogger: SupabaseLogger, Sendable {
    private let lock = NSLock()
    private var loggers: [String: Logger] = [:]

    func log(message: SupabaseLogMessage) {
        lock.withLock {
            let category = message.system
            if loggers[category] == nil {
                loggers[category] = Logger(category: category)
            }

            guard let logger = loggers[category] else { return }

            switch message.level {
            case .debug: logger.debug("\(message)")
            case .error: logger.error("\(message)")
            case .verbose: logger.info("\(message)")
            case .warning: logger.notice("\(message)")
            }
        }
    }
}
