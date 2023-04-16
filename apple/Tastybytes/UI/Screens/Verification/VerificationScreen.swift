import SwiftUI

struct VerificationScreen: View {
  enum VerificationType: String, CaseIterable, Identifiable {
    var id: Self { self }

    case products, brands, subBrands, companies

    var label: String {
      switch self {
      case .products:
        return "Products"
      case .brands:
        return "Brands"
      case .companies:
        return "Companies"
      case .subBrands:
        return "Sub-brands"
      }
    }
  }

  private let logger = getLogger(category: "ProductVerificationScreen")
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager
  @State private var products = [Product.Joined]()
  @State private var companies = [Company]()
  @State private var brands = [Brand.JoinedSubBrandsProductsCompany]()
  @State private var subBrands = [SubBrand.JoinedBrand]()
  @State private var verificationType: VerificationType = .products
  @State private var deleteProduct: Product.Joined? {
    didSet {
      showDeleteProductConfirmationDialog = true
    }
  }

  @State private var showDeleteProductConfirmationDialog = false

  var body: some View {
    List {
      switch verificationType {
      case .products:
        unverifiedProducts
      case .companies:
        unverifiedCompanies
      case .brands:
        unverifiedBrands
      case .subBrands:
        unverifiedSubBrands
      }
    }
    .listStyle(.plain)
    .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                        isPresented: $showDeleteProductConfirmationDialog,
                        titleVisibility: .visible,
                        presenting: deleteProduct)
    { presenting in
      ProgressButton(
        "Delete \(presenting.getDisplayName(.fullName))",
        role: .destructive,
        action: { await deleteProduct(onDelete: {
          hapticManager.trigger(.notification(.success))
        })
        }
      )
    }
    .navigationBarTitle("Unverified \(verificationType.label)")
    .toolbar {
      toolbarContent
    }
    .onChange(of: verificationType, perform: { _ in Task {
      await loadData()
    }
    })
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await loadData(refresh: true)
      }
    }
    .task {
      await loadData()
    }
  }

  private var unverifiedCompanies: some View {
    ForEach(companies) { company in
      RouterLink(company.name, screen: .company(company))
        .swipeActions {
          ProgressButton("Verify", systemImage: "checkmark", action: { await verifyCompany(company) }).tint(.green)
        }
    }
  }

  private var unverifiedSubBrands: some View {
    ForEach(subBrands) { subBrand in
      HStack {
        Text("\(subBrand.brand.brandOwner.name): \(subBrand.brand.name): \(subBrand.name ?? "-")")
        Spacer()
      }
      .onTapGesture {
        router.fetchAndNavigateTo(client, .brand(id: subBrand.brand.id))
      }
      .accessibilityAddTraits(.isButton)
      .swipeActions {
        ProgressButton("Verify", systemImage: "checkmark", action: { await verifySubBrand(subBrand) }).tint(.green)
      }
    }
  }

  private var unverifiedBrands: some View {
    ForEach(brands) { brand in
      RouterLink(screen: .brand(brand)) {
        HStack {
          Text("\(brand.brandOwner.name): \(brand.name)")
          Spacer()
          Text("(\(brand.getNumberOfProducts()))")
        }
      }
      .swipeActions {
        ProgressButton("Verify", systemImage: "checkmark", action: { await verifyBrand(brand) }).tint(.green)
      }
    }
  }

  private var unverifiedProducts: some View {
    ForEach(products) { product in
      VStack {
        if let createdBy = product.createdBy {
          HStack {
            AvatarView(avatarUrl: createdBy.avatarUrl, size: 16, id: createdBy.id)
            Text(createdBy.preferredName).font(.caption).bold()
            Spacer()
            if let createdAt = product.createdAt, let date = Date(timestamptzString: createdAt) {
              Text(date.customFormat(.relativeTime)).font(.caption).bold()
            }
          }
        }
        ProductItemView(product: product)
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(screen: .product(product))
          }
          .swipeActions {
            ProgressButton("Verify", systemImage: "checkmark", action: { await verifyProduct(product) }).tint(.green)
            RouterLink("Edit", systemImage: "pencil", sheet: .editProduct(product: product, onEdit: {
              await loadData(refresh: true)
            })).tint(.yellow)
            Button("Delete", systemImage: "trash", role: .destructive, action: { deleteProduct = product })
          }
      }
    }
  }

  private var toolbarContent: some ToolbarContent {
    ToolbarTitleMenu {
      ForEach(VerificationType.allCases) { type in
        Button {
          verificationType = type
        } label: {
          Text("Unverified \(type.label)")
        }
      }
    }
  }

  func verifyBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) async {
    switch await client.brand.verification(id: brand.id, isVerified: true) {
    case .success:
      withAnimation {
        brands.remove(object: brand)
      }
    case let .failure(error):
      logger.error("failed to verify brand \(brand.id): \(error.localizedDescription)")
    }
  }

  func verifySubBrand(_ subBrand: SubBrand.JoinedBrand) async {
    switch await client.subBrand.verification(id: subBrand.id, isVerified: true) {
    case .success:
      withAnimation {
        subBrands.remove(object: subBrand)
      }
    case let .failure(error):
      logger.error("failed to verify brand \(subBrand.id): \(error.localizedDescription)")
    }
  }

  func verifyCompany(_ company: Company) async {
    switch await client.company.verification(id: company.id, isVerified: true) {
    case .success:
      withAnimation {
        companies.remove(object: company)
      }
    case let .failure(error):
      logger.error("failed to verify company: \(error.localizedDescription)")
    }
  }

  func verifyProduct(_ product: Product.Joined) async {
    switch await client.product.verification(id: product.id, isVerified: true) {
    case .success:
      withAnimation {
        products.remove(object: product)
      }
    case let .failure(error):
      logger.error("failed to verify product: \(error.localizedDescription)")
    }
  }

  func deleteProduct(onDelete: @escaping () -> Void) async {
    guard let deleteProduct else { return }
    switch await client.product.delete(id: deleteProduct.id) {
    case .success:
      await loadData(refresh: true)
      onDelete()
    case let .failure(error):
      logger.error("failed to delete product: \(error.localizedDescription)")
    }
  }

  func loadData(refresh: Bool = false) async {
    switch verificationType {
    case .products:
      if refresh || products.isEmpty {
        switch await client.product.getUnverified() {
        case let .success(products):
          withAnimation {
            self.products = products
          }
        case let .failure(error):
          logger.error("loading unverfied products failed: \(error.localizedDescription)")
        }
      }
    case .companies:
      if refresh || companies.isEmpty {
        switch await client.company.getUnverified() {
        case let .success(companies):
          withAnimation {
            self.companies = companies
          }
        case let .failure(error):
          logger.error("loading unverfied companies failed: \(error.localizedDescription)")
        }
      }
    case .brands:
      if refresh || brands.isEmpty {
        switch await client.brand.getUnverified() {
        case let .success(brands):
          withAnimation {
            self.brands = brands
          }
        case let .failure(error):
          logger.error("loading unverfied brands failed: \(error.localizedDescription)")
        }
      }
    case .subBrands:
      if refresh || subBrands.isEmpty {
        switch await client.subBrand.getUnverified() {
        case let .success(subBrands):
          withAnimation {
            self.subBrands = subBrands
          }
        case let .failure(error):
          logger.error("loading unverfied sub-brands failed: \(error.localizedDescription)")
        }
      }
    }
  }
}
