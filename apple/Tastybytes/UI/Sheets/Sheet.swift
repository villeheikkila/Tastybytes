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
             mode: BrandSheet.Mode,
             onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void)
  case addBrand(brandOwner: Company,
                mode: BrandSheet.Mode,
                onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void)
  case subcategory(
    subcategories: Binding<[Subcategory]>,
    category: Category.JoinedSubcategoriesServingStyles
  )
  case subBrand(brandWithSubBrands: Brand.JoinedSubBrands,
                onSelect: (_ subBrand: SubBrand, _ createdNew: Bool) -> Void)
  case addProductToBrand(brand: Brand.JoinedSubBrandsProductsCompany, onCreate: ((_ product: Product.Joined) -> Void)?)
  case editProduct(product: Product.Joined, onEdit: (() async -> Void)? = nil)
  case productEditSuggestion(product: Product.Joined)
  case duplicateProduct(mode: DuplicateProductSheet.Mode, product: Product.Joined)
  case barcodeManagement(product: Product.Joined)
  case editBrand(brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: () async -> Void)
  case editSubBrand(brand: Brand.JoinedSubBrandsProductsCompany, subBrand: SubBrand.JoinedProduct, onUpdate: () async -> Void)
  case friends(taggedFriends: Binding<[Profile]>)
  case flavors(pickedFlavors: Binding<[Flavor]>)
  case locationSearch(onSelect: (_ location: Location) -> Void)
  case legacyPhotoPicker(onSelection: (_ image: UIImage) -> Void)
  case newFlavor(onSubmit: (_ newFlavor: String) async -> Void)
  case servingStyleManagement(pickedServingStyles: Binding<[ServingStyle]>,
                              onSelect: (_ servingStyle: ServingStyle) async -> Void)
  case categoryServingStyle(category: Category.JoinedSubcategoriesServingStyles)
  case editSubcategory(subcategory: Subcategory, onSubmit: (_ subcategoryName: String) async -> Void)
  case addSubcategory(category: CategoryProtocol, onSubmit: (_ newSubcategoryName: String) async -> Void)
  case addCategory(onSubmit: (_ newCategoryName: String) async -> Void)
  case editCompany(company: Company, onSuccess: () async -> Void)
  case companyEditSuggestion(company: Company, onSuccess: () -> Void)
  case userSheet(mode: UserSheet.Mode, onSubmit: () -> Void)
  case support

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
    case let .addBrand(brandOwner: brandOwner, mode: mode, onSelect: onSelect):
      BrandSheet(brandOwner: brandOwner, mode: mode, onSelect: onSelect)
    case let .brand(brandOwner, mode, onSelect):
      BrandSheet(brandOwner: brandOwner, mode: mode, onSelect: onSelect)
    case let .subBrand(brandWithSubBrands, onSelect):
      SubBrandSheet(brandWithSubBrands: brandWithSubBrands, onSelect: onSelect)
    case let .subcategory(subcategories, category):
      SubcategorySheet(subcategories: subcategories, category: category)
    case let .companySearch(onSelect):
      CompanySearchSheet(onSelect: onSelect)
    case let .barcodeManagement(product):
      BarcodeManagementSheet(product: product)
    case let .productEditSuggestion(product: product):
      DismissableSheet(title: "Edit Suggestion") { _ in
        AddProductView(mode: .editSuggestion(product))
      }
    case let .editProduct(product: product, onEdit: onEdit):
      DismissableSheet(title: "Edit Product") { dismiss in
        AddProductView(mode: .edit(product), onEdit: {
          if let onEdit {
            await onEdit()
          }
          dismiss()
        })
      }
    case let .addProductToBrand(brand: brand, onCreate: onCreate):
      DismissableSheet(title: "Add Product") { dismiss in
        AddProductView(mode: .addToBrand(brand), onCreate: { product in
          if let onCreate {
            onCreate(product)
          }
          dismiss()
        })
      }
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
    case let .locationSearch(onSelect: onSelect):
      LocationSearchSheet(onSelect: onSelect)
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
    case .support:
      SupportSheet()
    }
  }

  var detents: Set<PresentationDetent> {
    switch self {
    case .barcodeScanner, .productFilter, .newFlavor, .editSubcategory, .addCategory, .addSubcategory, .userSheet:
      return [.medium]
    case .nameTag:
      return [.height(320)]
    default:
      return [.large]
    }
  }

  var background: Material {
    switch self {
    case .support:
      return .ultraThin
    case .productFilter, .nameTag, .barcodeScanner:
      return .thickMaterial
    default:
      return .ultraThick
    }
  }

  var cornerRadius: CGFloat? {
    switch self {
    case .barcodeScanner, .nameTag:
      return 30
    default:
      return nil
    }
  }

  var id: String {
    switch self {
    case .report:
      return "report"
    case .checkIn:
      return "check_in"
    case .newCheckIn:
      return "new_check_in"
    case .productFilter:
      return "product_filter"
    case .barcodeScanner:
      return "barcode_scanner"
    case .nameTag:
      return "name_tag"
    case .companySearch:
      return "company_search"
    case .brand:
      return "brand"
    case .addBrand:
      return "add_brand"
    case .subBrand:
      return "sub_brand"
    case .subcategory:
      return "subcategory"
    case .editProduct:
      return "product"
    case .productEditSuggestion:
      return "product_edit_suggestion"
    case .duplicateProduct:
      return "duplicate_product"
    case .barcodeManagement:
      return "barcode_management"
    case .editBrand:
      return "edit_brand"
    case .editSubBrand:
      return "edit_sub_brand"
    case .addProductToBrand:
      return "add_product_to_brand"
    case .friends:
      return "friends"
    case .flavors:
      return "flavors"
    case .locationSearch:
      return "location_search"
    case .legacyPhotoPicker:
      return "legacy_photo_picker"
    case .newFlavor:
      return "new_flavor"
    case .servingStyleManagement:
      return "serving_style_management"
    case .categoryServingStyle:
      return "category_serving_style"
    case .addCategory:
      return "add_category"
    case .addSubcategory:
      return "add_subcategory"
    case .editSubcategory:
      return "edit_subcategory"
    case .editCompany:
      return "edit_company"
    case .companyEditSuggestion:
      return "company_edit_suggestion"
    case .userSheet:
      return "user"
    case .support:
      return "support"
    }
  }

  static func == (lhs: Sheet, rhs: Sheet) -> Bool {
    lhs.id == rhs.id
  }
}
