import Model
import SwiftUI

enum Sheet: Identifiable, Equatable {
    case report(Report.Entity)
    case checkIn(CheckIn, onUpdate: (_ checkIn: CheckIn) -> Void)
    case newCheckIn(Product.Joined, onCreation: (_ checkIn: CheckIn) async -> Void)
    case barcodeScanner(onComplete: (_ barcode: Barcode) -> Void)
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
        category: Model.Category.JoinedSubcategoriesServingStyles
    )
    case subBrand(brandWithSubBrands: Brand.JoinedSubBrands, subBrand: Binding<SubBrandProtocol?>)
    case addProductToBrand(brand: Brand.JoinedSubBrandsProductsCompany)
    case addProductToSubBrand(brand: Brand.JoinedSubBrandsProductsCompany, subBrand: SubBrand.JoinedProduct)
    case productEdit(product: Product.Joined, onEdit: (() async -> Void)? = nil)
    case productEditSuggestion(product: Product.Joined)
    case duplicateProduct(mode: DuplicateProductSheet.Mode, product: Product.Joined)
    case barcodeManagement(product: Product.Joined)
    case editBrand(brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: () async -> Void)
    case editSubBrand(
        brand: Brand.JoinedSubBrandsProductsCompany,
        subBrand: SubBrand.JoinedProduct,
        onUpdate: () async -> Void
    )
    case friends(taggedFriends: Binding<[Profile]>)
    case flavors(pickedFlavors: Binding<[Flavor]>)
    case locationSearch(title: String, onSelect: (_ location: Location) -> Void)
    case legacyPhotoPicker(onSelection: (_ image: UIImage) -> Void)
    case newFlavor(onSubmit: (_ newFlavor: String) async -> Void)
    case servingStyleManagement(pickedServingStyles: Binding<[ServingStyle]>,
                                onSelect: (_ servingStyle: ServingStyle) async -> Void)
    case categoryServingStyle(category: Model.Category.JoinedSubcategoriesServingStyles)
    case editSubcategory(subcategory: Subcategory, onSubmit: (_ subcategoryName: String) async -> Void)
    case addSubcategory(category: CategoryProtocol, onSubmit: (_ newSubcategoryName: String) async -> Void)
    case addCategory(onSubmit: (_ newCategoryName: String) async -> Void)
    case editCompany(company: Company, onSuccess: () async -> Void)
    case companyEditSuggestion(company: Company, onSuccess: () -> Void)
    case userSheet(mode: UserSheet.Mode, onSubmit: () -> Void)
    case checkInDatePicker(checkInAt: Binding<Date>, isLegacyCheckIn: Binding<Bool>)
    case categoryPickerSheet(category: Binding<Model.Category.JoinedSubcategoriesServingStyles?>)
    case mergeLocationSheet(location: Location)
    case productLogo(product: Product.Joined, onUpload: () async -> Void)
    case subscribe
    case sendEmail(email: Binding<Email>, callback: SendMailCallback)

    @ViewBuilder var view: some View {
        switch self {
        case let .report(entity):
            ReportSheet(entity: entity)
        case let .checkIn(checkIn, onUpdate):
            CheckInSheet(checkIn: checkIn, onUpdate: onUpdate)
        case let .newCheckIn(product, onCreation):
            CheckInSheet(product: product, onCreation: onCreation)
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
        case let .productEditSuggestion(product: product):
            ProductMutationView(mode: .editSuggestion(product))
        case let .productEdit(product: product, onEdit: onEdit):
            ProductMutationView(mode: .edit(product), onEdit: onEdit)
        case let .addProductToBrand(brand: brand):
            ProductMutationView(mode: .addToBrand(brand))
        case let .addProductToSubBrand(brand: brand, subBrand: subBrand):
            ProductMutationView(mode: .addToSubBrand(brand, subBrand))
        case let .duplicateProduct(mode: mode, product: product):
            DuplicateProductSheet(mode: mode, product: product)
        case let .editBrand(brand: brand, onUpdate):
            EditBrandSheet(brand: brand, onUpdate: onUpdate)
        case let .editSubBrand(brand: brand, subBrand: subBrand, onUpdate):
            EditSubBrandSheet(brand: brand, subBrand: subBrand, onUpdate: onUpdate)
        case let .friends(taggedFriends: taggedFriends):
            FriendSheet(taggedFriends: taggedFriends)
        case let .flavors(pickedFlavors: pickedFlavors):
            FlavorSheet(pickedFlavors: pickedFlavors)
        case let .locationSearch(title: title, onSelect: onSelect):
            LocationSearchSheet(title: title, onSelect: onSelect)
        case let .legacyPhotoPicker(onSelection: onSelection):
            LegacyPhotoPicker(onSelection: onSelection)
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
        case let .editCompany(company: company, onSuccess: onSuccess):
            EditCompanySheet(company: company, onSuccess: onSuccess, mode: .edit)
        case let .companyEditSuggestion(company: company, onSuccess: onSuccess):
            EditCompanySheet(company: company, onSuccess: onSuccess, mode: .editSuggestion)
        case let .userSheet(mode: mode, onSubmit: onSubmit):
            UserSheet(mode: mode, onSubmit: onSubmit)
        case let .checkInDatePicker(checkInAt: checkInAt, isLegacyCheckIn: isLegacyCheckIn):
            CheckInDatePickerSheet(checkInAt: checkInAt, isLegacyCheckIn: isLegacyCheckIn)
        case let .categoryPickerSheet(category: category):
            CategoryPickerSheet(category: category)
        case .subscribe:
            SubscriptionSheet()
        case let .mergeLocationSheet(location: location):
            MergeLocationSheet(location: location)
        case let .productLogo(product, onUpload):
            ProductLogoSheet(product: product, onUpload: onUpload)
        case let .sendEmail(email, callback):
            SendEmailView(email: email, callback: callback)
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
        default:
            [.large]
        }
    }

    var background: Material {
        switch self {
        case .subscribe, .checkIn:
            .thickMaterial
        case .productFilter, .nameTag, .barcodeScanner, .checkInDatePicker:
            .thickMaterial
        default:
            .ultraThick
        }
    }

    var cornerRadius: CGFloat? {
        switch self {
        case .barcodeScanner, .nameTag:
            30
        default:
            nil
        }
    }

    var id: String {
        switch self {
        case .report:
            "report"
        case let .checkIn(checkIn, _):
            "check_in_\(checkIn.hashValue)"
        case .newCheckIn:
            "new_check_in"
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
        case let .productEdit(product, _):
            "edit_product_\(product.hashValue)"
        case .productEditSuggestion:
            "product_edit_suggestion"
        case .duplicateProduct:
            "duplicate_product"
        case .barcodeManagement:
            "barcode_management"
        case let .editBrand(brand, _):
            "edit_brand_\(brand.hashValue)"
        case let .editSubBrand(brand, subBrand, _):
            "edit_sub_brand_\(brand.hashValue)_\(subBrand.hashValue)"
        case .addProductToBrand:
            "add_product_to_brand"
        case .addProductToSubBrand:
            "add_product_to_sub_brand"
        case .friends:
            "friends"
        case .flavors:
            "flavors"
        case .locationSearch:
            "location_search"
        case .legacyPhotoPicker:
            "legacy_photo_picker"
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
        case let .editCompany(company, _):
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
        case let .mergeLocationSheet(location):
            "location_management_\(location.hashValue)"
        case let .productLogo(product, _):
            "product_logo_\(product.hashValue)"
        case .sendEmail:
            "send_email"
        }
    }

    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
}
