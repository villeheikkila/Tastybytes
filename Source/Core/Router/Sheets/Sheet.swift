import Components
import CoreLocation
import Models
import SwiftUI

enum Sheet: Identifiable, Equatable {
    case report(Report.Entity)
    case checkIn(CheckInSheet.Action)
    case barcodeScanner(onComplete: (_ barcode: Barcode) async -> Void)
    case productFilter(initialFilter: Product.Filter?, sections: [ProductFilterSheet.Sections], onApply: (_ filter: Product.Filter?) -> Void)
    case nameTag(onSuccess: (_ profileId: UUID) -> Void)
    case companySearch(onSelect: (_ company: Company) -> Void)
    case brand(brandOwner: Company, brand: Binding<Brand.JoinedSubBrands?>, mode: BrandPickerSheet.Mode)
    case addBrand(brandOwner: Company, mode: BrandPickerSheet.Mode)
    case subcategory(subcategories: Binding<[Subcategory]>, category: Models.Category.JoinedSubcategoriesServingStyles)
    case subBrand(brandWithSubBrands: Brand.JoinedSubBrands, subBrand: Binding<SubBrandProtocol?>)
    case product(_ mode: ProductMutationView.Mode)
    case duplicateProduct(mode: ProductDuplicateScreen.Mode, product: Product.Joined)
    case brandAdmin(brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: BrandAdminSheet.BrandUpdateCallback, onDelete: BrandAdminSheet.BrandUpdateCallback)
    case subBrandAdmin(brand: Binding<Brand.JoinedSubBrandsProductsCompany>, subBrand: SubBrand.JoinedProduct)
    case friends(taggedFriends: Binding<[Profile]>)
    case flavors(pickedFlavors: Binding<[Flavor]>)
    case checkInLocationSearch(category: Location.RecentLocation, title: LocalizedStringKey, initialLocation: Binding<Location?>, onSelect: (_ location: Location) -> Void)
    case locationSearch(initialLocation: Location?, initialSearchTerm: String?, onSelect: (_ location: Location) -> Void)
    case newFlavor(onSubmit: (_ newFlavor: String) async -> Void)
    case servingStyleManagement(pickedServingStyles: Binding<[ServingStyle]>, onSelect: (_ servingStyle: ServingStyle) async -> Void)
    case subcategoryAdmin(subcategory: Subcategory.JoinedCategory, onSubmit: (_ subcategoryName: String) async -> Void)
    case subcategoryCreation(category: CategoryProtocol, onSubmit: (_ newSubcategoryName: String) async -> Void)
    case categoryCreation(onSubmit: (_ newCategoryName: String) async -> Void)
    case companyEditSuggestion(company: Company, onSuccess: () -> Void)
    case user(mode: UserPickerSheet.Mode, onSubmit: () -> Void)
    case checkInDatePicker(checkInAt: Binding<Date>, isLegacyCheckIn: Binding<Bool>, isNostalgic: Binding<Bool>)
    case categoryPicker(category: Binding<Models.Category.JoinedSubcategoriesServingStyles?>)
    case mergeLocation(location: Location, onMerge: ((_ newLocation: Location) async -> Void)? = nil)
    case subscribe
    case sendEmail(email: Binding<Email>, callback: SendMailCallback)
    case editComment(checkInComment: CheckInComment, checkInComments: Binding<[CheckInComment]>)
    case checkInImage(checkIn: CheckIn, onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?)
    case profileDeleteConfirmation
    case webView(link: WebViewLink)
    case companyAdmin(company: Company, onUpdate: () async -> Void, onDelete: () -> Void)
    case locationAdmin(location: Location, onEdit: (_ location: Location) async -> Void, onDelete: (_ location: Location) async -> Void)
    case profileAdmin(profile: Profile, onDelete: (_ profile: Profile) -> Void)
    case productAdmin(product: Binding<Product.Joined>, onDelete: () -> Void)
    case checkInAdmin(checkIn: CheckIn, onDelete: () -> Void)
    case checkInCommentAdmin(checkIn: CheckIn, checkInComment: CheckInComment, onDelete: (_ comment: CheckInComment) -> Void)
    case checkInImageAdmin(checkIn: CheckIn, imageEntity: ImageEntity, onDelete: (_ comment: ImageEntity) async -> Void)
    case categoryAdmin(category: Models.Category.JoinedSubcategoriesServingStyles)

    @MainActor
    @ViewBuilder var view: some View {
        switch self {
        case let .report(entity):
            ReportSheet(entity: entity)
        case let .checkIn(action):
            CheckInSheet(action: action)
        case let .barcodeScanner(onComplete: onComplete):
            BarcodeScannerSheet(onComplete: onComplete)
        case let .productFilter(initialFilter, sections, onApply):
            ProductFilterSheet(initialFilter: initialFilter, sections: sections, onApply: onApply)
        case let .nameTag(onSuccess):
            NameTagSheet(onSuccess: onSuccess)
        case let .addBrand(brandOwner: brandOwner, mode: mode):
            BrandPickerSheet(brand: .constant(nil), brandOwner: brandOwner, mode: mode)
        case let .brand(brandOwner, brand: brand, mode: mode):
            BrandPickerSheet(brand: brand, brandOwner: brandOwner, mode: mode)
        case let .subBrand(brandWithSubBrands, subBrand: subBrand):
            SubBrandPickerSheet(subBrand: subBrand, brandWithSubBrands: brandWithSubBrands)
        case let .subcategory(subcategories, category):
            SubcategoryPickerSheet(subcategories: subcategories, category: category)
        case let .companySearch(onSelect):
            CompanyPickerSheet(onSelect: onSelect)
        case let .product(mode):
            ProductMutationView(mode: mode)
        case let .duplicateProduct(mode: mode, product: product):
            ProductDuplicateScreen(mode: mode, product: product)
        case let .brandAdmin(brand: brand, onUpdate, onDelete: onDelete):
            BrandAdminSheet(brand: brand, onUpdate: onUpdate, onDelete: onDelete)
        case let .subBrandAdmin(brand: brand, subBrand: subBrand):
            SubBrandAdminSheet(brand: brand, subBrand: subBrand)
        case let .friends(taggedFriends: taggedFriends):
            FriendPickerSheet(taggedFriends: taggedFriends)
        case let .flavors(pickedFlavors: pickedFlavors):
            FlavorPickerSheet(pickedFlavors: pickedFlavors)
        case let .checkInLocationSearch(category: category, title: title, initialLocation, onSelect: onSelect):
            CheckInLocationSearchSheet(category: category, title: title, initialLocation: initialLocation, onSelect: onSelect)
        case let .newFlavor(onSubmit: onSubmit):
            NewFlavorSheet(onSubmit: onSubmit)
        case let .servingStyleManagement(pickedServingStyles: pickedServingStyles, onSelect: onSelect):
            ServingStyleManagementSheet(pickedServingStyles: pickedServingStyles, onSelect: onSelect)
        case let .subcategoryAdmin(subcategory: subcategory, onSubmit: onSubmit):
            SubcategoryAdminSheet(subcategory: subcategory, onSubmit: onSubmit)
        case let .subcategoryCreation(category: category, onSubmit: onSubmit):
            SubcategoryCreationSheet(category: category, onSubmit: onSubmit)
        case let .categoryCreation(onSubmit: onSubmit):
            CategoryCreationSheet(onSubmit: onSubmit)
        case let .companyAdmin(company, onUpdate, onDelete):
            CompanyAdminSheet(company: company, onUpdate: onUpdate, onDelete: onDelete)
        case let .companyEditSuggestion(company: company, onSuccess: onSuccess):
            CompanyEditSuggestionSheet(company: company, onSuccess: onSuccess)
        case let .user(mode: mode, onSubmit: onSubmit):
            UserPickerSheet(mode: mode, onSubmit: onSubmit)
        case let .checkInDatePicker(checkInAt: checkInAt, isLegacyCheckIn: isLegacyCheckIn, isNostalgic: isNostalgic):
            CheckInDatePickerSheet(checkInAt: checkInAt, isLegacyCheckIn: isLegacyCheckIn, isNostalgic: isNostalgic)
        case let .categoryPicker(category: category):
            CategoryPickerSheet(category: category)
        case .subscribe:
            SubscriptionSheet()
        case let .mergeLocation(location, onMerge):
            MergeLocationSheet(location: location, onMerge: onMerge)
        case let .sendEmail(email, callback):
            SendEmailView(email: email, callback: callback)
                .ignoresSafeArea(edges: .bottom)
        case let .editComment(checkInComment, checkInComments):
            CheckInCommentEditSheet(checkInComment: checkInComment, checkInComments: checkInComments)
        case let .checkInImage(checkIn, onDeleteImage):
            CheckInImageSheet(checkIn: checkIn, onDeleteImage: onDeleteImage)
        case .profileDeleteConfirmation:
            AccountDeletedScreen()
        case let .locationAdmin(location, onEdit, onDelete):
            LocationAdminSheet(location: location, onEdit: onEdit, onDelete: onDelete)
        case let .webView(link):
            WebViewSheet(link: link)
        case let .locationSearch(initialLocation, initialSearchTerm, onSelect):
            LocationSearchSheet(initialLocation: initialLocation, initialSearchTerm: initialSearchTerm, onSelect: onSelect)
        case let .profileAdmin(profile, onDelete):
            ProfileAdminSheet(profile: profile, onDelete: onDelete)
        case let .productAdmin(product, onDelete):
            ProductAdminSheet(product: product, onDelete: onDelete)
        case let .checkInAdmin(checkIn, onDelete):
            CheckInAdminSheet(checkIn: checkIn, onDelete: onDelete)
        case let .checkInCommentAdmin(checkIn, checkInComment, onDelete):
            CheckInCommentAdminSheet(checkIn: checkIn, comment: checkInComment, onDelete: onDelete)
        case let .checkInImageAdmin(checkIn, imageEntity, onDelete):
            CheckInImageAdminSheet(checkIn: checkIn, imageEntity: imageEntity, onDelete: onDelete)
        case let .categoryAdmin(category):
            CategoryAdminSheet(category: category)
        }
    }

    var detents: Set<PresentationDetent> {
        switch self {
        case .barcodeScanner, .productFilter, .newFlavor, .categoryCreation, .subcategoryCreation, .user:
            [.medium]
        case .nameTag:
            [.height(320)]
        case .checkInDatePicker:
            [.height(500)]
        case .editComment:
            [.height(200)]
        default:
            [.large]
        }
    }

    var backgroundDark: Material {
        .ultraThin
    }

    var backgroundLight: Material {
        .thin
    }

    var cornerRadius: CGFloat? {
        switch self {
        case .barcodeScanner, .nameTag:
            30
        default:
            nil
        }
    }

    nonisolated var id: String {
        switch self {
        case .report:
            "report"
        case let .checkIn(checkIn):
            "check_in_\(checkIn.hashValue)"
        case .productFilter:
            "product_filter"
        case .barcodeScanner:
            "barcode_scanner"
        case .nameTag:
            "name_tag"
        case .companySearch:
            "company_search"
        case let .brand(brandOwner, _, _):
            "brand_\(brandOwner.hashValue)"
        case let .addBrand(brandOwner, brand):
            "add_brand_\(brandOwner.hashValue)_\(brand.hashValue)"
        case let .subBrand(subBrand, _):
            "sub_brand_\(subBrand.hashValue)"
        case .subcategory:
            "subcategory"
        case let .product(mode):
            "edit_product_\(mode)"
        case .duplicateProduct:
            "duplicate_product"
        case let .brandAdmin(brand, _, _):
            "brand_admin_\(brand.hashValue)"
        case let .subBrandAdmin(_, subBrand):
            "sub_brand_admin_\(subBrand.hashValue)"
        case .friends:
            "friends"
        case .flavors:
            "flavors"
        case .checkInLocationSearch:
            "location_search"
        case .newFlavor:
            "new_flavor"
        case .servingStyleManagement:
            "serving_style_management"
        case .categoryCreation:
            "add_category"
        case .subcategoryCreation:
            "add_subcategory"
        case let .subcategoryAdmin(subcategory, _):
            "edit_subcategory_\(subcategory.hashValue)"
        case let .companyAdmin(company, _, _):
            "edit_company_\(company.hashValue)"
        case .companyEditSuggestion:
            "company_edit_suggestion"
        case .user:
            "user"
        case .checkInDatePicker:
            "check_in_date_picker"
        case .categoryPicker:
            "category_picker"
        case .subscribe:
            "support"
        case let .mergeLocation(location, _):
            "location_management_\(location.hashValue)"
        case .sendEmail:
            "send_email"
        case let .editComment(checkInComment, _):
            "edit_comment_\(checkInComment.hashValue)"
        case let .checkInImage(checkIn, _):
            "check_in_image_\(checkIn.hashValue)"
        case .profileDeleteConfirmation:
            "profile_delete_confirmation"
        case let .locationAdmin(location, _, _):
            "location_admin_\(location)"
        case let .webView(link):
            "webview_\(link)"
        case let .locationSearch(initialLocation, initialSearchTerm, _):
            "location_search_\(String(describing: initialLocation))_\(initialSearchTerm ?? "")"
        case let .profileAdmin(profile, _):
            "profile_admin_sheet_\(profile)"
        case let .productAdmin(product, _):
            "product_admin_\(product)"
        case let .checkInAdmin(checkIn, _):
            "check_in_admin_\(checkIn)"
        case let .checkInCommentAdmin(checkIn, checkInComment, _):
            "check_in_comment_admin_\(checkIn)_\(checkInComment)"
        case let .checkInImageAdmin(checkIn, imageEntity, _):
            "check_in_image_admin_\(checkIn)_\(imageEntity)"
        case let .categoryAdmin(category):
            "category_admin_\(category)"
        }
    }

    nonisolated static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}
