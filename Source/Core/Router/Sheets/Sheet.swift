import Components
import CoreLocation
import Models
import SwiftUI

enum Sheet: Identifiable, Equatable {
    case report(Report.Content)
    case checkIn(CheckInSheet.Action)
    case barcodeScanner(onComplete: (_ barcode: Barcode) async -> Void)
    case productFilter(initialFilter: Product.Filter?, sections: [ProductFilterSheet.Sections], onApply: (_ filter: Product.Filter?) -> Void)
    case nameTag(onSuccess: (_ profileId: Profile.Id) -> Void)
    case companyPicker(filterCompanies: [Company.Saved] = [], onSelect: (_ company: Company.Saved) -> Void)
    case brandPicker(brandOwner: any CompanyProtocol, brand: Binding<Brand.JoinedSubBrands?>, mode: BrandPickerSheet.Mode)
    case subcategoryPicker(subcategories: Binding<[Subcategory.Saved]>, category: Models.Category.JoinedSubcategoriesServingStyles)
    case subBrandPicker(brandWithSubBrands: Brand.JoinedSubBrands, subBrand: Binding<SubBrandProtocol?>)
    case product(_ mode: ProductMutationView.Mode)
    case productPicker(product: Binding<Product.Joined?>)
    case brandAdmin(
        id: Brand.Id,
        open: BrandAdminSheet.Open? = nil,
        onUpdate: BrandAdminSheet.OnUpdateCallback = noop,
        onDelete: BrandAdminSheet.OnDeleteCallback = noop
    )
    case subBrandAdmin(
        id: SubBrand.Id,
        open: SubBrandAdminSheet.Open? = nil,
        onUpdate: SubBrandAdminSheet.OnUpdateCallback = noop,
        onDelete: SubBrandAdminSheet.OnDeleteCallback = noop
    )
    case friendPicker(taggedFriends: Binding<[Profile.Saved]>)
    case flavorPicker(pickedFlavors: Binding<[Flavor.Saved]>)
    case checkInLocationSearch(
        category: Location.RecentLocation,
        title: LocalizedStringKey,
        initialLocation: Binding<Location.Saved?>,
        onSelect: (_ location: Location.Saved) -> Void
    )
    case locationSearch(initialLocation: Location.Saved?, initialSearchTerm: String?, onSelect: (_ location: Location.Saved) -> Void)
    case newFlavor(onSubmit: (_ newFlavor: String) async -> Void)
    case servingStyleManagement(
        pickedServingStyles: Binding<[ServingStyle.Saved]>,
        onSelect: (_ servingStyle: ServingStyle.Saved) async -> Void
    )
    case subcategoryAdmin(id: Subcategory.Id, onEdit: SubcategoryAdminSheet.OnEditCallback = noop)
    case subcategoryCreation(category: CategoryProtocol, onSubmit: (_ newSubcategoryName: String) async -> Void)
    case categoryCreation(onSubmit: (_ newCategoryName: String) async -> Void)
    case companyEditSuggestion(company: any CompanyProtocol, onSuccess: () -> Void)
    case profilePicker(mode: ProfilePickerSheet.Mode, onSubmit: () -> Void)
    case checkInDatePicker(checkInAt: Binding<Date>, isLegacyCheckIn: Binding<Bool>, isNostalgic: Binding<Bool>)
    case categoryPicker(category: Binding<Models.Category.JoinedSubcategoriesServingStyles?>)
    case mergeLocation(location: Location.Detailed, onMerge: ((_ newLocation: Location.Detailed) async -> Void)? = nil)
    case subscribe
    case sendEmail(email: Binding<Email>, callback: SendMailCallback)
    case editComment(checkInComment: CheckIn.Comment.Saved, checkInComments: Binding<[CheckIn.Comment.Saved]>)
    case checkInImage(checkIn: CheckIn.Joined, onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?)
    case profileDeleteConfirmation
    case webView(link: WebViewLink)
    case companyAdmin(id: Company.Id, open: CompanyAdminSheet.Open? = nil, onUpdate: CompanyAdminSheet.OnUpdateCallback = noop, onDelete: CompanyAdminSheet.OnDeleteCallback = noop)
    case locationAdmin(id: Location.Id, open: LocationAdminSheet.Open? = nil, onEdit: LocationAdminSheet.OnEditCallback = noop, onDelete: LocationAdminSheet.OnDeleteCallback = noop)
    case profileAdmin(id: Profile.Id, open: ProfileAdminSheet.Open? = nil, onDelete: ProfileAdminSheet.OnDeleteCallback = noop)
    case productAdmin(
        id: Product.Id,
        open: ProductAdminSheet.Open? = nil,
        onUpdate: ProductAdminSheet.OnUpdateCallback = noop,
        onDelete: ProductAdminSheet.OnDeleteCallback = noop
    )
    case checkInAdmin(
        id: CheckIn.Id,
        open: CheckInAdminSheet.Open? = nil,
        onUpdate: CheckInAdminSheet.OnUpdateCallback = noop,
        onDelete: CheckInAdminSheet.OnDeleteCallback = noop
    )
    case checkInCommentAdmin(
        id: CheckIn.Comment.Id,
        open: CheckInCommentAdminSheet.Open? = nil,
        onDelete: CheckInCommentAdminSheet.OnDeleteCallback = noop
    )
    case checkInImageAdmin(
        id: ImageEntity.Id,
        open: CheckInImageAdminSheet.Open? = nil,
        onDelete: CheckInImageAdminSheet.OnDeleteCallback = noop
    )
    case categoryAdmin(id: Models.Category.Id)
    case brandEditSuggestion(brand: Brand.JoinedSubBrandsCompany, onSuccess: () -> Void)
    case subBrandEditSuggestion(brand: Brand.JoinedSubBrands, subBrand: SubBrand.JoinedBrand, onSuccess: () -> Void)
    case settings
    case privacyPolicy
    case termsOfService

    @MainActor
    @ViewBuilder var view: some View {
        switch self {
        case let .report(content):
            ReportSheet(reportContent: content)
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
        case let .productPicker(product: product):
            ProductPickerSheet(product: product)
        case let .brandAdmin(id, open, onUpdate, onDelete):
            BrandAdminSheet(id: id, open: open, onUpdate: onUpdate, onDelete: onDelete)
        case let .subBrandAdmin(id, open, onUpdate, onDelete):
            SubBrandAdminSheet(id: id, open: open, onUpdate: onUpdate, onDelete: onDelete)
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
        case let .subcategoryAdmin(id: id, onEdit):
            SubcategoryAdminSheet(id: id, onEdit: onEdit)
        case let .subcategoryCreation(category: category, onSubmit: onSubmit):
            SubcategoryCreationSheet(category: category, onSubmit: onSubmit)
        case let .categoryCreation(onSubmit: onSubmit):
            CategoryCreationSheet(onSubmit: onSubmit)
        case let .companyAdmin(id, open, onUpdate, onDelete):
            CompanyAdminSheet(id: id, open: open, onUpdate: onUpdate, onDelete: onDelete)
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
        case let .locationAdmin(id, open: open, onEdit, onDelete):
            LocationAdminSheet(id: id, open: open, onEdit: onEdit, onDelete: onDelete)
        case let .webView(link):
            WebViewSheet(link: link)
        case let .locationSearch(initialLocation, initialSearchTerm, onSelect):
            LocationSearchSheet(initialLocation: initialLocation, initialSearchTerm: initialSearchTerm, onSelect: onSelect)
        case let .profileAdmin(id, open, onDelete):
            ProfileAdminSheet(id: id, open: open, onDelete: onDelete)
        case let .productAdmin(id, open, onUpdate, onDelete):
            ProductAdminSheet(id: id, open: open, onUpdate: onUpdate, onDelete: onDelete)
        case let .checkInAdmin(id, open, onUpdate, onDelete):
            CheckInAdminSheet(id: id, open: open, onUpdate: onUpdate, onDelete: onDelete)
        case let .checkInCommentAdmin(id, open, onDelete):
            CheckInCommentAdminSheet(id: id, open: open, onDelete: onDelete)
        case let .checkInImageAdmin(id, open, onDelete):
            CheckInImageAdminSheet(id: id, open: open, onDelete: onDelete)
        case let .categoryAdmin(id):
            CategoryAdminSheet(id: id)
        case let .brandEditSuggestion(brand, onSuccess):
            BrandEditSuggestionSheet(brand: brand, onSuccess: onSuccess)
        case let .subBrandEditSuggestion(brand, subBrand, onSuccess):
            SubBrandEditSuggestionSheet(brand: brand, subBrand: subBrand, onSuccess: onSuccess)
        case .settings:
            SettingsScreen()
        case .privacyPolicy:
            PrivacyPolicySheet()
        case .termsOfService:
            TermsOfServiceSheet()
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
        case let .productPicker(product):
            "duplicate_product_\(String(describing: product.wrappedValue))"
        case let .brandAdmin(id, _, _, _):
            "brand_admin_\(id)"
        case let .subBrandAdmin(id, _, _, _):
            "sub_brand_admin_\(id)"
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
        case let .subcategoryAdmin(id, _):
            "edit_subcategory_\(id)"
        case let .companyAdmin(company, _, _, _):
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
            "check_in_image_\(checkIn.id)"
        case .profileDeleteConfirmation:
            "profile_delete_confirmation"
        case let .locationAdmin(id, _, _, _):
            "location_admin_\(id)"
        case let .webView(link):
            "webview_\(link)"
        case let .locationSearch(initialLocation, initialSearchTerm, _):
            "location_search_\(String(describing: initialLocation))_\(initialSearchTerm ?? "")"
        case let .profileAdmin(id, _, _):
            "profile_admin_sheet_\(id)"
        case let .productAdmin(id, _, _, _):
            "product_admin_\(id)"
        case let .checkInAdmin(id, _, _, _):
            "check_in_admin_\(id)"
        case let .checkInCommentAdmin(id, _, _):
            "check_in_comment_admin_\(id)"
        case let .checkInImageAdmin(checkIn, imageEntity, _):
            "check_in_image_admin_\(checkIn)_\(String(describing: imageEntity))"
        case let .categoryAdmin(id):
            "category_admin_\(id)"
        case let .brandEditSuggestion(brand, _):
            "brand_edit_suggestion_\(brand)"
        case let .subBrandEditSuggestion(brand, subBrand, _):
            "brand_edit_suggestion_\(brand)_\(subBrand)"
        case .settings:
            "settings"
        case .privacyPolicy:
            "privacyPolicy"
        case .termsOfService:
            "termsOfService"
        }
    }

    nonisolated static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}
