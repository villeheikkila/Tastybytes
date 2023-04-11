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

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductVerificationScreen")
    let client: Client

    @Published var products = [Product.Joined]()
    @Published var companies = [Company]()
    @Published var brands = [Brand.JoinedSubBrandsProductsCompany]()
    @Published var subBrands = [SubBrand.JoinedBrand]()
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
}