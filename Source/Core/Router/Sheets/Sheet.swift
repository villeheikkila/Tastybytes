import Components
import CoreLocation
import Models
import SwiftUI

enum Sheet: Identifiable, Equatable {
    case report(Report.Entity)
    case checkIn(CheckInSheet.Action)
    case barcodeScanner(onComplete: (_ barcode: Barcode) async -> Void)
    case productFilter(initialFilter: Product.Filter?, sections: [ProductFilterSheet.Sections], onApply: (_ filter: Product.Filter?) -> Void)
    case nameTag(onSuccess: (_ profileId: Profile.Id) -> Void)
    case companyPicker(filterCompanies: [Company] = [], onSelect: (_ company: Company) -> Void)
    case brandPicker(brandOwner: Company, brand: Binding<Brand.JoinedSubBrands?>, mode: BrandPickerSheet.Mode)
    case subcategoryPicker(subcategories: Binding<[Subcategory]>, category: Models.Category.JoinedSubcategoriesServingStyles)
    case subBrandPicker(brandWithSubBrands: Brand.JoinedSubBrands, subBrand: Binding<SubBrandProtocol?>)
    case product(_ mode: ProductMutationView.Mode)
    case duplicateProduct(mode: ProductDuplicateScreen.Mode, product: Product.Joined)
    case brandAdmin(brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: BrandAdminSheet.BrandUpdateCallback, onDelete: BrandAdminSheet.BrandUpdateCallback)
    case subBrandAdmin(brand: Binding<Brand.JoinedSubBrandsProductsCompany>, subBrand: SubBrand.JoinedProduct)
    case friendPicker(taggedFriends: Binding<[Profile]>)
    case flavorPicker(pickedFlavors: Binding<[Flavor]>)
    case checkInLocationSearch(category: Location.RecentLocation, title: LocalizedStringKey, initialLocation: Binding<Location?>, onSelect: (_ location: Location) -> Void)
    case locationSearch(initialLocation: Location?, initialSearchTerm: String?, onSelect: (_ location: Location) -> Void)
    case newFlavor(onSubmit: (_ newFlavor: String) async -> Void)
    case servingStyleManagement(pickedServingStyles: Binding<[ServingStyle]>, onSelect: (_ servingStyle: ServingStyle) async -> Void)
    case subcategoryAdmin(subcategory: SubcategoryProtocol, onSubmit: (_ subcategoryName: String) async -> Void)
    case subcategoryCreation(category: CategoryProtocol, onSubmit: (_ newSubcategoryName: String) async -> Void)
    case categoryCreation(onSubmit: (_ newCategoryName: String) async -> Void)
    case companyEditSuggestion(company: Company, onSuccess: () -> Void)
    case profilePicker(mode: ProfilePickerSheet.Mode, onSubmit: () -> Void)
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
    case productAdmin(product: ProductProtocol, onDelete: () -> Void, onUpdate: () async -> Void)
    case checkInAdmin(checkIn: CheckIn, onDelete: () -> Void)
    case checkInCommentAdmin(checkIn: CheckIn, checkInComment: CheckInComment, onDelete: (_ comment: CheckInComment) -> Void)
    case checkInImageAdmin(checkIn: CheckIn, imageEntity: ImageEntity, onDelete: (_ comment: ImageEntity) async -> Void)
    case categoryAdmin(category: Models.Category.JoinedSubcategoriesServingStyles)
    case brandEditSuggestion(brand: Brand.JoinedSubBrandsProductsCompany, onSuccess: () -> Void)
    case subBrandEditSuggestion(brand: Brand.JoinedSubBrands, subBrand: SubBrand.JoinedBrand, onSuccess: () -> Void)
    case settings

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
        case let .brandPicker(brandOwner, brand: brand, mode: mode):
            BrandPickerSheet(brand: brand, brandOwner: brandOwner, mode: mode)
        case let .subBrandPicker(brandWithSubBrands, subBrand: subBrand):
            SubBrandPickerSheet(subBrand: subBrand, brandWithSubBrands: brandWithSubBrands)
        case let .subcategoryPicker(subcategories, category):
            SubcategoryPickerSheet(subcategories: subcategories, category: category)
        case let .companyPicker(filterCompanies, onSelect):
            CompanyPickerSheet(filterCompanies: filterCompanies, onSelect: onSelect)
        case let .product(mode):
            ProductMutationView(mode: mode)
        case let .duplicateProduct(mode: mode, product: product):
            ProductDuplicateScreen(mode: mode, product: product)
        case let .brandAdmin(brand: brand, onUpdate, onDelete: onDelete):
            BrandAdminSheet(brand: brand, onUpdate: onUpdate, onDelete: onDelete)
        case let .subBrandAdmin(brand: brand, subBrand: subBrand):
            SubBrandAdminSheet(brand: brand, subBrand: subBrand)
        case let .friendPicker(taggedFriends: taggedFriends):
            FriendPickerSheet(taggedFriends: taggedFriends)
        case let .flavorPicker(pickedFlavors: pickedFlavors):
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
        case let .profilePicker(mode: mode, onSubmit: onSubmit):
            ProfilePickerSheet(mode: mode, onSubmit: onSubmit)
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
        case let .productAdmin(product, onDelete, onUpdate):
            ProductAdminSheet(product: product, onDelete: onDelete, onUpdate: onUpdate)
        case let .checkInAdmin(checkIn, onDelete):
            CheckInAdminSheet(checkIn: checkIn, onDelete: onDelete)
        case let .checkInCommentAdmin(checkIn, checkInComment, onDelete):
            CheckInCommentAdminSheet(checkIn: checkIn, comment: checkInComment, onDelete: onDelete)
        case let .checkInImageAdmin(checkIn, imageEntity, onDelete):
            CheckInImageAdminSheet(checkIn: checkIn, imageEntity: imageEntity, onDelete: onDelete)
        case let .categoryAdmin(category):
            CategoryAdminSheet(category: category)
        case let .brandEditSuggestion(brand, onSuccess):
            BrandEditSuggestionSheet(brand: brand, onSuccess: onSuccess)
        case let .subBrandEditSuggestion(brand, subBrand, onSuccess):
            SubBrandEditSuggestionSheet(brand: brand, subBrand: subBrand, onSuccess: onSuccess)
        case .settings:
            SettingsScreen()
        }
    }

    var detents: Set<PresentationDetent> {
        switch self {
        case .barcodeScanner, .productFilter, .newFlavor, .categoryCreation, .subcategoryCreation, .profilePicker:
            [.medium]
        case .nameTag:
            [.height(320)]
        case .companyEditSuggestion:
            [.height(200)]
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
        case .companyPicker:
            "company_search"
        case let .brandPicker(brandOwner, _, _):
            "brand_\(brandOwner.hashValue)"
        case let .subBrandPicker(subBrand, _):
            "sub_brand_\(subBrand.hashValue)"
        case .subcategoryPicker:
            "subcategory"
        case let .product(mode):
            "edit_product_\(mode)"
        case .duplicateProduct:
            "duplicate_product"
        case let .brandAdmin(brand, _, _):
            "brand_admin_\(brand.hashValue)"
        case let .subBrandAdmin(_, subBrand):
            "sub_brand_admin_\(subBrand.hashValue)"
        case .friendPicker:
            "friends"
        case .flavorPicker:
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
            "edit_subcategory_\(subcategory.id)"
        case let .companyAdmin(company, _, _):
            "edit_company_\(company.hashValue)"
        case .companyEditSuggestion:
            "company_edit_suggestion"
        case .profilePicker:
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
        case let .productAdmin(product, _, _):
            "product_admin_\(product)"
        case let .checkInAdmin(checkIn, _):
            "check_in_admin_\(checkIn)"
        case let .checkInCommentAdmin(checkIn, checkInComment, _):
            "check_in_comment_admin_\(checkIn)_\(checkInComment)"
        case let .checkInImageAdmin(checkIn, imageEntity, _):
            "check_in_image_admin_\(checkIn)_\(imageEntity)"
        case let .categoryAdmin(category):
            "category_admin_\(category)"
        case let .brandEditSuggestion(brand, _):
            "brand_edit_suggestion_\(brand)"
        case let .subBrandEditSuggestion(brand, subBrand, _):
            "brand_edit_suggestion_\(brand)_\(subBrand)"
        case .settings:
            "settings"
        }
    }

    nonisolated static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}
