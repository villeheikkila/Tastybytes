import Components
import CoreLocation
import Models
import SwiftUI

enum Sheet: Identifiable, Equatable {
    case report(Report.Entity)
    case checkIn(CheckInSheet.Action)
    case barcodeScanner(onComplete: (_ barcode: Barcode) async -> Void)
    case productFilter(
        initialFilter: Product.Filter?,
        sections: [ProductFilterSheet.Sections],
        onApply: (_ filter: Product.Filter?) -> Void
    )
    case nameTag(onSuccess: (_ profileId: UUID) -> Void)
    case companySearch(onSelect: (_ company: Company) -> Void)
    case brand(brandOwner: Company,
               brand: Binding<Brand.JoinedSubBrands?>,
               mode: BrandSheet.Mode)
    case addBrand(brandOwner: Company, mode: BrandSheet.Mode)
    case subcategory(
        subcategories: Binding<[Subcategory]>,
        category: Models.Category.JoinedSubcategoriesServingStyles
    )
    case subBrand(brandWithSubBrands: Brand.JoinedSubBrands, subBrand: Binding<SubBrandProtocol?>)
    case product(_ mode: ProductMutationView.Mode)
    case duplicateProduct(mode: DuplicateProductSheet.Mode, product: Product.Joined)
    case barcodeManagement(product: Product.Joined)
    case brandAdmin(brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: BrandAdminSheet.BrandUpdateCallback)
    case subBrandAdmin(
        brand: Binding<Brand.JoinedSubBrandsProductsCompany>,
        subBrand: SubBrand.JoinedProduct,
        onUpdate: SubBrandAdminSheet.UpdateSubBrandCallback,
        onDelete: SubBrandAdminSheet.UpdateSubBrandCallback
    )
    case friends(taggedFriends: Binding<[Profile]>)
    case flavors(pickedFlavors: Binding<[Flavor]>)
    case checkInLocationSearch(
        category: Location.RecentLocation,
        title: LocalizedStringKey,
        initialLocation: Binding<Location?>,
        onSelect: (_ location: Location) -> Void
    )
    case locationSearch(initialLocation: Location?, initialSearchTerm: String?, onSelect: (_ location: Location) -> Void)
    case newFlavor(onSubmit: (_ newFlavor: String) async -> Void)
    case servingStyleManagement(pickedServingStyles: Binding<[ServingStyle]>,
                                onSelect: (_ servingStyle: ServingStyle) async -> Void)
    case categoryServingStyle(category: Models.Category.JoinedSubcategoriesServingStyles)
    case editSubcategory(subcategory: Subcategory, onSubmit: (_ subcategoryName: String) async -> Void)
    case addSubcategory(category: CategoryProtocol, onSubmit: (_ newSubcategoryName: String) async -> Void)
    case addCategory(onSubmit: (_ newCategoryName: String) async -> Void)
    case companyAdmin(company: Company, onSuccess: () async -> Void)
    case companyEditSuggestion(company: Company, onSuccess: () -> Void)
    case userSheet(mode: UserSheet.Mode, onSubmit: () -> Void)
    case checkInDatePicker(checkInAt: Binding<Date>, isLegacyCheckIn: Binding<Bool>, isNostalgic: Binding<Bool>)
    case categoryPickerSheet(category: Binding<Int?>)
    case mergeLocationSheet(location: Location, onMerge: ((_ newLocation: Location) async -> Void)? = nil)
    case subscribe
    case sendEmail(email: Binding<Email>, callback: SendMailCallback)
    case editComment(checkInComment: CheckInComment, checkInComments: Binding<[CheckInComment]>)
    case checkInImage(checkIn: CheckIn, onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?)
    case profileDeleteConfirmation
    case locationAdmin(location: Location, onEdit: (_ location: Location) async -> Void, onDelete: (_ location: Location) async -> Void)
    case webView(link: WebViewLink)
    case profileAdmin(profile: Profile)
    case productAdmin(product: Binding<Product.Joined>)

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
            BrandSheet(brand: .constant(nil), brandOwner: brandOwner, mode: mode)
        case let .brand(brandOwner, brand: brand, mode: mode):
            BrandSheet(brand: brand, brandOwner: brandOwner, mode: mode)
        case let .subBrand(brandWithSubBrands, subBrand: subBrand):
            SubBrandSheet(subBrand: subBrand, brandWithSubBrands: brandWithSubBrands)
        case let .subcategory(subcategories, category):
            SubcategorySheet(subcategories: subcategories, category: category)
        case let .companySearch(onSelect):
            CompanySearchSheet(onSelect: onSelect)
        case let .barcodeManagement(product):
            BarcodeManagementSheet(product: product)
        case let .product(mode):
            ProductMutationView(mode: mode)
        case let .duplicateProduct(mode: mode, product: product):
            DuplicateProductSheet(mode: mode, product: product)
        case let .brandAdmin(brand: brand, onUpdate):
            BrandAdminSheet(brand: brand, onUpdate: onUpdate)
        case let .subBrandAdmin(brand: brand, subBrand: subBrand, onUpdate, onDelete: onDelete):
            SubBrandAdminSheet(brand: brand, subBrand: subBrand, onUpdate: onUpdate, onDelete: onDelete)
        case let .friends(taggedFriends: taggedFriends):
            FriendSheet(taggedFriends: taggedFriends)
        case let .flavors(pickedFlavors: pickedFlavors):
            FlavorSheet(pickedFlavors: pickedFlavors)
        case let .checkInLocationSearch(category: category, title: title, initialLocation, onSelect: onSelect):
            CheckInLocationSearchSheet(category: category, title: title, initialLocation: initialLocation, onSelect: onSelect)
        case let .newFlavor(onSubmit: onSubmit):
            NewFlavorSheet(onSubmit: onSubmit)
        case let .servingStyleManagement(pickedServingStyles: pickedServingStyles, onSelect: onSelect):
            ServingStyleManagementSheet(pickedServingStyles: pickedServingStyles, onSelect: onSelect)
        case let .categoryServingStyle(category: category):
            CategoryServingStyleSheet(category: category)
        case let .editSubcategory(subcategory: subcategory, onSubmit: onSubmit):
            EditSubcategorySheet(subcategory: subcategory, onSubmit: onSubmit)
        case let .addSubcategory(category: category, onSubmit: onSubmit):
            AddSubcategorySheet(category: category, onSubmit: onSubmit)
        case let .addCategory(onSubmit: onSubmit):
            AddCategorySheet(onSubmit: onSubmit)
        case let .companyAdmin(company: company, onSuccess: onSuccess):
            CompanyAdminSheet(company: company, onSuccess: onSuccess)
        case let .companyEditSuggestion(company: company, onSuccess: onSuccess):
            CompanyEditSuggestionSheet(company: company, onSuccess: onSuccess)
        case let .userSheet(mode: mode, onSubmit: onSubmit):
            UserSheet(mode: mode, onSubmit: onSubmit)
        case let .checkInDatePicker(checkInAt: checkInAt, isLegacyCheckIn: isLegacyCheckIn, isNostalgic: isNostalgic):
            CheckInDatePickerSheet(checkInAt: checkInAt, isLegacyCheckIn: isLegacyCheckIn, isNostalgic: isNostalgic)
        case let .categoryPickerSheet(category: category):
            CategoryPickerSheet(category: category)
        case .subscribe:
            SubscriptionSheet()
        case let .mergeLocationSheet(location, onMerge):
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
        case let .profileAdmin(profile):
            ProfileAdminSheet(profile: profile)
        case let .productAdmin(product):
            ProductAdminSheet(product: product)
        }
    }

    var detents: Set<PresentationDetent> {
        switch self {
        case .barcodeScanner, .productFilter, .newFlavor, .editSubcategory, .addCategory, .addSubcategory, .userSheet:
            [.medium]
        case .nameTag:
            [.height(320)]
        case .checkInDatePicker:
            [.height(500)]
        case .editComment:
            [.height(120)]
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
        case .barcodeManagement:
            "barcode_management"
        case let .brandAdmin(brand, _):
            "brand_admin_\(brand.hashValue)"
        case let .subBrandAdmin(_, subBrand, _, _):
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
        case .categoryServingStyle:
            "category_serving_style"
        case .addCategory:
            "add_category"
        case .addSubcategory:
            "add_subcategory"
        case let .editSubcategory(subcategory, _):
            "edit_subcategory_\(subcategory.hashValue)"
        case let .companyAdmin(company, _):
            "edit_company_\(company.hashValue)"
        case .companyEditSuggestion:
            "company_edit_suggestion"
        case .userSheet:
            "user"
        case .checkInDatePicker:
            "check_in_date_picker"
        case .categoryPickerSheet:
            "category_picker"
        case .subscribe:
            "support"
        case let .mergeLocationSheet(location, _):
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
        case let .profileAdmin(profile):
            "profile_admin_sheet_\(profile)"
        case let .productAdmin(product):
            "product_admin_\(product)"
        }
    }

    nonisolated static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}
