import Foundation
import OSLog
import Supabase

public protocol RepositoryProtocol: Sendable {
    var appConfig: AppConfigRepository { get }
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
    var subscription: SubscriptionRepository { get }
    var imageEntity: ImageEntityRepository { get }
}
