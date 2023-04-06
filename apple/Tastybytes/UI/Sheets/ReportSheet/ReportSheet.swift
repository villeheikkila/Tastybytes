import SwiftUI

struct ReportSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router

  init(_ client: Client, entity: ReportableEntity) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, entity: entity))
  }

  @State private var commentText: String = ""

  var body: some View {
    Form {
      Section {
        reportedEntityView
      }
      Section {
        TextField("Message", text: $commentText, axis: .vertical)
        Button(action: { viewModel.submitReport() }, label: {
          Text("Submit").bold()
        })
      } header: {
        Text("Report")
      }
    }
    .navigationTitle("Report")
    .navigationBarItems(leading: Button(role: .cancel, action: { router.sheet = nil }, label: {
      Text("Close").bold()
    }))
  }

  @ViewBuilder
  private var reportedEntityView: some View {
    switch viewModel.entity {
    case let .product(product):
      ProductItemView(product: product, extras: [.companyLink, .logo])
    case let .company(company):
      HStack {
        Text(company.name)
      }
    case let .brand(brand):
      HStack {
        Text(brand.name)
      }
    case let .subBrand(brand, subBrand):
      HStack {
        Text("\(subBrand.name ?? "Default") sub-brand from \(brand.name)")
      }
    case let .comment(comment):
      CheckInCommentView(comment: comment)
    case let .checkIn(checkIn):
      CheckInCardView(client: viewModel.client, checkIn: checkIn, loadedFrom: .product)
    }
  }
}

extension ReportSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ReportSheet")
    let client: Client
    let entity: ReportableEntity

    init(_ client: Client, entity: ReportableEntity) {
      self.client = client
      self.entity = entity
    }

    func submitReport() {}
  }
}

enum ReportableEntity: Hashable {
  case product(Product.Joined)
  case company(Company)
  case brand(Brand.JoinedSubBrandsProductsCompany)
  case subBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct)
  case checkIn(CheckIn)
  case comment(CheckInComment)
}

struct ReportButton: View {
  @EnvironmentObject private var router: Router
  let entity: ReportableEntity

  var body: some View {
    Button(action: { router.sheet = .report(entity) }, label: {
      Label("Report", systemImage: "exclamationmark.bubble.fill")
    })
  }
}
