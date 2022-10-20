let supabaseRepository = SupabaseRepository()

protocol Repository {
    var profile: ProfileRepository { get }
    var checkIn: CheckInRepository { get }
    var checkInComment: CheckInCommentRepository { get }
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
    let product: ProductRepository
    let auth: AuthRepository
    let company: CompanyRepository
    let friend: FriendRepository
    let category: CategoryRepository
    let brand: BrandRepository
    let subBrand: SubBrandRepository
    let flavor: FlavorRepository
        
    init() {
        self.profile = SupabaseProfileRepository()
        self.checkIn = SupabaseCheckInRepository()
        self.checkInComment = SupabaseCheckInCommentRepository()
        self.product = SupabaseProductRepository()
        self.auth = SupabaseAuthRepository()
        self.company = SupabaseCompanyRepository()
        self.friend = SupabaseFriendsRepository()
        self.category = SupabaseCategoryRepository()
        self.brand = SupabaseBrandRepository()
        self.subBrand = SupabaseSubBrandRepository()
        self.flavor = SupabaseFlavorRepository()
    }
}
