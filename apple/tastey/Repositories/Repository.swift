import Supabase
import SwiftUI
let repository = SupabaseRepository(Supabase.client)

protocol Repository {
    var profile: ProfileRepository { get }
    var checkIn: CheckInRepository { get }
    var checkInComment: CheckInCommentRepository { get }
    var checkInReactions: CheckInReactionsRepository { get }
    var product: ProductRepository { get }
    var auth: AuthRepository { get }
    var company: CompanyRepository { get }
    var friend: FriendRepository { get }
    var category: CategoryRepository { get }
    var brand: BrandRepository { get }
    var subBrand: SubBrandRepository { get }
    var flavor: FlavorRepository { get }
}

class SupabaseRepository: Repository {
    let profile: ProfileRepository
    let checkIn: CheckInRepository
    let checkInComment: CheckInCommentRepository
    let checkInReactions: CheckInReactionsRepository
    let product: ProductRepository
    let auth: AuthRepository
    let company: CompanyRepository
    let friend: FriendRepository
    let category: CategoryRepository
    let brand: BrandRepository
    let subBrand: SubBrandRepository
    let flavor: FlavorRepository
        
    init(_ client: SupabaseClient) {
        self.profile = SupabaseProfileRepository(client: client)
        self.checkIn = SupabaseCheckInRepository(client: client)
        self.checkInComment = SupabaseCheckInCommentRepository(client: client)
        self.checkInReactions = SupabaseCheckInReactionsRepository(client: client)
        self.product = SupabaseProductRepository(client: client)
        self.auth = SupabaseAuthRepository(client: client)
        self.company = SupabaseCompanyRepository(client: client)
        self.friend = SupabaseFriendsRepository(client: client)
        self.category = SupabaseCategoryRepository(client: client)
        self.brand = SupabaseBrandRepository(client: client)
        self.subBrand = SupabaseSubBrandRepository(client: client)
        self.flavor = SupabaseFlavorRepository(client: client)
    }
}
