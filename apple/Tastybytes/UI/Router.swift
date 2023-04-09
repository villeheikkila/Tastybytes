import os
import SwiftUI

struct InitializeRouter<Content: View>: View {
  @StateObject private var router = Router()
  let client: Client
  var content: (_ router: Router) -> Content

  init(_ client: Client, content: @escaping (_ router: Router) -> Content) {
    self.client = client
    self.content = content
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      content(router)
        .withRoutes(client)
        .withSheets(client, sheetRoute: $router.sheet, nestedSheetRoute: $router.nestedSheet)
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(client, detailPage, resetStack: true)
          }
        }
    }
    .environmentObject(router)
  }
}

@MainActor
class Router: ObservableObject {
  private let logger = getLogger(category: "Router")
  @Published var path: [Route] = []
  @Published var sheet: Sheet?
  @Published var nestedSheet: Sheet?

  func navigate(to: Route, resetStack: Bool) {
    if resetStack {
      path = []
    }
    path.append(to)
  }

  func openSheet(_ to: Sheet) {
    if sheet != nil {
      nestedSheet = to
    } else {
      sheet = to
    }
  }

  func reset() {
    path = []
  }

  func removeLast() {
    path.removeLast()
  }

  func fetchAndNavigateTo(_ client: Client, _ destination: NavigatablePath, resetStack: Bool) {
    Task {
      switch destination {
      case let .product(id):
        switch await client.product.getById(id: id) {
        case let .success(product):
          self.navigate(to: .product(product), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for product with \(id) failed: \(error.localizedDescription)")
        }
      case let .checkIn(id):
        switch await client.checkIn.getById(id: id) {
        case let .success(checkIn):
          self.navigate(to: .checkIn(checkIn), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for check-in with \(id) failed: \(error.localizedDescription)")
        }
      case let .company(id):
        switch await client.company.getById(id: id) {
        case let .success(company):
          self.navigate(to: .company(company), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for company with \(id) failed: \(error.localizedDescription)")
        }
      case let .brand(id):
        switch await client.brand.getJoinedById(id: id) {
        case let .success(brand):
          self.navigate(to: .brand(brand), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for brand with \(id) failed: \(error.localizedDescription)")
        }
      case let .profile(id):
        switch await client.profile.getById(id: id) {
        case let .success(profile):
          self.navigate(to: .profile(profile), resetStack: resetStack)
        case let .failure(error):
          logger
            .error(
              "request for profile with \(id.uuidString.lowercased()) failed: \(error.localizedDescription)"
            )
        }
      case let .location(id):
        switch await client.location.getById(id: id) {
        case let .success(location):
          self.navigate(to: .location(location), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for location with \(id) failed: \(error.localizedDescription)")
        }
      }
    }
  }
}

enum Route: Hashable {
  case product(Product.Joined)
  case profile(Profile)
  case checkIn(CheckIn)
  case location(Location)
  case company(Company)
  case brand(Brand.JoinedSubBrandsProductsCompany)
  case profileProducts(Profile)
  case profileStatistics(Profile)
  case settings
  case currentUserFriends
  case friends(Profile)
  case addProduct(Barcode?)
  case productFeed(Product.FeedType)
  case flavorManagementScreen
  case verificationScreen
  case duplicateProducts
  case categoryManagement
}

extension View {
  func withRoutes(_ client: Client) -> some View {
    navigationDestination(for: Route.self) { route in
      switch route {
      case let .company(company):
        CompanyScreen(client, company: company)
      case let .brand(brand):
        BrandScreen(client, brand: brand)
      case .currentUserFriends:
        CurrentUserFriendsScreen(client)
      case .settings:
        SettingsScreen(client)
      case let .location(location):
        LocationScreen(client, location: location)
      case let .profileProducts(profile):
        ProfileProductListView(client, profile: profile)
      case let .profileStatistics(profile):
        ProfileStatisticsView(client, profile: profile)
      case let .addProduct(initialBarcode):
        AddProductView(client, mode: .new, initialBarcode: initialBarcode)
          .navigationTitle("Add Product")
      case let .checkIn(checkIn):
        CheckInScreen(client, checkIn: checkIn)
      case let .profile(profile):
        ProfileScreen(client, profile: profile)
      case let .product(product):
        ProductScreen(client, product: product)
      case let .friends(profile):
        FriendsScreen(client, profile: profile)
      case let .productFeed(feed):
        ProductFeedScreen(client, feed: feed)
      case .flavorManagementScreen:
        FlavorManagementScreen(client)
      case .verificationScreen:
        VerificationScreen(client)
      case .duplicateProducts:
        DuplicateProductScreen(client)
      case .categoryManagement:
        CategoryManagementScreen(client)
      }
    }
  }

  func withSheets(_ client: Client, sheetRoute: Binding<Sheet?>, nestedSheetRoute: Binding<Sheet?>) -> some View {
    sheet(item: sheetRoute) { sheet in
      NavigationStack {
        Group {
          SheetStack(client: client, sheet: sheet)
        }.sheet(item: nestedSheetRoute, content: { nestedSheet in
          NavigationStack {
            SheetStack(client: client, sheet: nestedSheet)
          }
          .presentationDetents(nestedSheet.detents)
          .presentationCornerRadius(nestedSheet.cornerRadius)
          .presentationBackground(nestedSheet.background)
        })
      }
      .presentationDetents(sheet.detents)
      .presentationCornerRadius(sheet.cornerRadius)
      .presentationBackground(sheet.background)
    }
  }
}

struct SheetStack: View {
  let client: Client
  let sheet: Sheet

  var body: some View {
    switch sheet {
    case let .report(entity):
      ReportSheet(client, entity: entity)
    case let .checkIn(checkIn, onUpdate):
      CheckInSheet(client, checkIn: checkIn, onUpdate: onUpdate)
    case let .newCheckIn(product, onCreation):
      CheckInSheet(client, product: product, onCreation: onCreation)
    case let .barcodeScanner(onComplete: onComplete):
      BarcodeScannerSheet(onComplete: onComplete)
    case let .productFilter(initialFilter, sections, onApply):
      ProductFilterSheet(client, initialFilter: initialFilter, sections: sections, onApply: onApply)
    case let .nameTag(onSuccess):
      NameTagSheet(onSuccess: onSuccess)
    case let .addBrand(brandOwner: brandOwner, mode: mode, onSelect: onSelect):
      BrandSheet(client, brandOwner: brandOwner, mode: mode, onSelect: onSelect)
    case let .brand(brandOwner, mode, onSelect):
      BrandSheet(client, brandOwner: brandOwner, mode: mode, onSelect: onSelect)
    case let .subBrand(brandWithSubBrands, onSelect):
      SubBrandSheet(client, brandWithSubBrands: brandWithSubBrands, onSelect: onSelect)
    case let .subcategory(subcategories, category, onCreate):
      SubcategorySheet(subcategories: subcategories, category: category, onCreate: onCreate)
    case let .companySearch(onSelect):
      CompanySearchSheet(client, onSelect: onSelect)
    case let .barcodeManagement(product):
      BarcodeManagementSheet(client, product: product)
    case let .productEditSuggestion(product: product):
      DismissableSheet(title: "Edit Suggestion") {
        AddProductView(client, mode: .editSuggestion(product))
      }
    case let .editProduct(product: product, onEdit: onEdit):
      DismissableSheet(title: "Edit Product") {
        AddProductView(client, mode: .edit(product), onEdit: onEdit)
      }
    case let .addProductToBrand(brand: brand, onCreate: onCreate):
      DismissableSheet(title: "Add Product") {
        AddProductView(client, mode: .addToBrand(brand), onCreate: onCreate)
      }
    case let .duplicateProduct(mode: mode, product: product):
      DuplicateProductSheet(client, mode: mode, product: product)
    case let .editBrand(brand: brand, onUpdate):
      EditBrandSheet(client, brand: brand, onUpdate: onUpdate)
    case let .editSubBrand(brand: brand, subBrand: subBrand, onUpdate):
      EditSubBrandSheet(client, brand: brand, subBrand: subBrand, onUpdate: onUpdate)
    case let .friends(taggedFriends: taggedFriends):
      FriendSheet(taggedFriends: taggedFriends)
    case let .flavors(pickedFlavors: pickedFlavors):
      FlavorSheet(pickedFlavors: pickedFlavors)
    case let .locationSearch(onSelect: onSelect):
      LocationSearchSheet(client, onSelect: onSelect)
    case let .legacyPhotoPicker(onSelection: onSelection):
      LegacyPhotoPicker(onSelection: onSelection)
    case let .newFlavor(onSubmit: onSubmit):
      NewFlavorSheet(onSubmit: onSubmit)
    case let .servingStyleManagement(pickedServingStyles: pickedServingStyles, onSelect: onSelect):
      ServingStyleManagementSheet(client, pickedServingStyles: pickedServingStyles, onSelect: onSelect)
    }
  }
}

enum Sheet: Identifiable {
  case report(Report.Entity)
  case checkIn(CheckIn, onUpdate: (_ checkIn: CheckIn) -> Void)
  case newCheckIn(Product.Joined, onCreation: (_ checkIn: CheckIn) -> Void)
  case barcodeScanner(onComplete: (_ barcode: Barcode) -> Void)
  case productFilter(initialFilter: Product.Filter?, sections: [Sections], onApply: (_ filter: Product.Filter?) -> Void)
  case nameTag(onSuccess: (_ profileId: UUID) -> Void)
  case companySearch(onSelect: (_ company: Company, _ createdNew: Bool) -> Void)
  case brand(brandOwner: Company,
             mode: BrandSheet.Mode,
             onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void)
  case addBrand(brandOwner: Company,
                mode: BrandSheet.Mode,
                onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void)
  case subcategory(
    subcategories: Binding<[Subcategory]>,
    category: Category.JoinedSubcategories,
    onCreate: (_ newSubcategoryName: String) -> Void
  )
  case subBrand(brandWithSubBrands: Brand.JoinedSubBrands,
                onSelect: (_ subBrand: SubBrand, _ createdNew: Bool) -> Void)
  case addProductToBrand(brand: Brand.JoinedSubBrandsProductsCompany, onCreate: ((_ product: Product.Joined) -> Void)?)
  case editProduct(product: Product.Joined, onEdit: (() -> Void)? = nil)
  case productEditSuggestion(product: Product.Joined)
  case duplicateProduct(mode: DuplicateProductSheet.Mode, product: Product.Joined)
  case barcodeManagement(product: Product.Joined)
  case editBrand(brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: () -> Void)
  case editSubBrand(brand: Brand.JoinedSubBrandsProductsCompany, subBrand: SubBrand.JoinedProduct, onUpdate: () -> Void)
  case friends(taggedFriends: Binding<[Profile]>)
  case flavors(pickedFlavors: Binding<[Flavor]>)
  case locationSearch(onSelect: (_ location: Location) -> Void)
  case legacyPhotoPicker(onSelection: (_ image: UIImage) -> Void)
  case newFlavor(onSubmit: (_ newFlavor: String) -> Void)
  case servingStyleManagement(pickedServingStyles: Binding<[ServingStyle]>,
                              onSelect: (_ servingStyle: ServingStyle) -> Void)

  var detents: Set<PresentationDetent> {
    switch self {
    case .barcodeScanner, .productFilter, .newFlavor:
      return [.medium]
    case .nameTag:
      return [.height(320)]
    default:
      return [.large]
    }
  }

  var background: Material {
    switch self {
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
    }
  }
}

enum NavigatablePath {
  case product(id: Int)
  case checkIn(id: Int)
  case company(id: Int)
  case profile(id: UUID)
  case location(id: UUID)
  case brand(id: Int)

  var urlString: String {
    switch self {
    case let .profile(id):
      return "\(Config.baseUrl)/\(PathIdentifier.profiles)/\(id.uuidString.lowercased())"
    case let .checkIn(id):
      return "\(Config.baseUrl)/\(PathIdentifier.checkins)/\(id)"
    case let .product(id):
      return "\(Config.baseUrl)/\(PathIdentifier.products)/\(id)"
    case let .company(id):
      return "\(Config.baseUrl)/\(PathIdentifier.companies)/\(id)"
    case let .brand(id):
      return "\(Config.baseUrl)/\(PathIdentifier.brands)/\(id)"
    case let .location(id):
      return "\(Config.baseUrl)/\(PathIdentifier.locations)/\(id.uuidString.lowercased())"
    }
  }

  var url: URL {
    // swiftlint:disable force_unwrapping
    URL(string: urlString)!
    // swiftlint:enable force_unwrapping
  }
}

enum PathIdentifier: Hashable {
  case checkins, products, profiles, companies, locations, brands
}

extension URL {
  var isUniversalLink: Bool {
    scheme == "https"
  }

  var pathIdentifier: PathIdentifier? {
    guard isUniversalLink, pathComponents.count == 3 else { return nil }

    switch pathComponents[1] {
    case "checkins": return .checkins
    case "products": return .products
    case "profiles": return .profiles
    case "companies": return .companies
    case "brands": return .brands
    case "locations": return .locations
    default: return nil
    }
  }

  var detailPage: NavigatablePath? {
    guard let pathIdentifier
    else {
      return nil
    }

    let path = pathComponents[2]

    switch pathIdentifier {
    case .products:
      guard let id = Int(path) else {
        return nil
      }
      return .product(id: id)
    case .checkins:
      guard let id = Int(path) else {
        return nil
      }
      return .checkIn(id: id)
    case .profiles:
      guard let uuid = UUID(uuidString: path) else {
        return nil
      }
      return .profile(id: uuid)
    case .brands:
      guard let id = Int(path) else {
        return nil
      }
      return .brand(id: id)
    case .companies:
      guard let id = Int(path) else {
        return nil
      }
      return .company(id: id)
    case .locations:
      guard let id = UUID(uuidString: path) else { return nil }
      return .location(id: id)
    }
  }
}
