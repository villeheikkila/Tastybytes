import SwiftUI

extension VerificationScreen {
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

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductVerificationScreen")
    let client: Client
    @Published var products = [Product.Joined]()
    @Published var companies = [Company]()
    @Published var brands = [Brand.JoinedSubBrandsProductsCompany]()
    @Published var editProduct: Product.Joined?
    @Published var verificationType: VerificationType = .products
    @Published var deleteProduct: Product.Joined? {
      didSet {
        showDeleteProductConfirmationDialog = true
      }
    }

    @Published var showDeleteProductConfirmationDialog = false

    init(_ client: Client) {
      self.client = client
    }

    func verifyBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) {
      Task {
        switch await client.brand.verification(id: brand.id, isVerified: true) {
        case .success:
          withAnimation {
            brands.remove(object: brand)
          }
        case let .failure(error):
          logger.error("failed to verify brand \(brand.id): \(error.localizedDescription)")
        }
      }
    }

    func verifyCompany(_ company: Company) {
      Task {
        switch await client.company.verification(id: company.id, isVerified: true) {
        case .success:
          withAnimation {
            companies.remove(object: company)
          }
        case let .failure(error):
          logger.error("failed to verify company \(company.id): \(error.localizedDescription)")
        }
      }
    }

    func verifyProduct(_ product: Product.Joined) {
      Task {
        switch await client.product.verification(id: product.id, isVerified: true) {
        case .success:
          withAnimation {
            products.remove(object: product)
          }
        case let .failure(error):
          logger.error("failed to verify product \(product.id): \(error.localizedDescription)")
        }
      }
    }

    func onEditProduct() {
      editProduct = nil
      Task {
        await loadProducts()
      }
    }

    func deleteProduct(onDelete: @escaping () -> Void) {
      if let deleteProduct {
        Task {
          switch await client.product.delete(id: deleteProduct.id) {
          case .success:
            onDelete()
          case let .failure(error):
            logger.error("failed to delete product \(deleteProduct.id): \(error.localizedDescription)")
          }
        }
      }
    }

    func refreshData() async {
      switch verificationType {
      case .products:
        await loadProducts()
      case .companies:
        await loadCompanies()
      case .brands:
        await loadBrands()
      case .subBrands:
        ()
      }
    }

    func loadData() async {
      switch verificationType {
      case .products:
        if products.isEmpty {
          await loadProducts()
        }
      case .companies:
        if companies.isEmpty {
          await loadCompanies()
        }
      case .brands:
        if brands.isEmpty {
          await loadBrands()
        }
      case .subBrands:
        ()
      }
    }

    func loadBrands() async {
      switch await client.brand.getUnverified() {
      case let .success(brands):
        withAnimation {
          self.brands = brands
        }
      case let .failure(error):
        logger
          .error(
            "loading unverfied brands failed: \(error.localizedDescription)"
          )
      }
    }

    func loadCompanies() async {
      switch await client.company.getUnverified() {
      case let .success(companies):
        withAnimation {
          self.companies = companies
        }
      case let .failure(error):
        logger
          .error(
            "loading unverfied companies failed: \(error.localizedDescription)"
          )
      }
    }

    func loadProducts() async {
      switch await client.product.getUnverified() {
      case let .success(products):
        withAnimation {
          self.products = products
        }
      case let .failure(error):
        logger
          .error(
            "loading unverfied products failed: \(error.localizedDescription)"
          )
      }
    }
  }
}
