import AlertToast
import SwiftUI

struct ReportSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, entity: Report.Entity) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, entity: entity))
  }

  var body: some View {
    Form {
      Section {
        reportedEntityView
      } header: {
        Text("Content in question")
      }
      Section {
        TextField("Reason", text: $viewModel.message, axis: .vertical)
          .lineLimit(8, reservesSpace: true)
        ProgressButton(action: {
          await viewModel.submitReport(onSubmit: {
            dismiss()
          })
        }, label: {
          Text("Submit").bold()
        })
      } header: {
        Text("Report")
      }
    }
    .navigationTitle("Report \(viewModel.entity.label)")
    .navigationBarItems(leading: Button(role: .cancel, action: { router.sheet = nil }, label: {
      Text("Close").bold()
    }))
    .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Report submitted!")
    }
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
    let entity: Report.Entity
    @Published var message = ""
    @Published var showToast = false

    init(_ client: Client, entity: Report.Entity) {
      self.client = client
      self.entity = entity
    }

    func submitReport(onSubmit _: @escaping () -> Void) async {
      switch await client.report.insert(report: Report.NewRequest(message: message, entity: entity)) {
      case .success:
        showToast = true
      case let .failure(error):
        logger.error("submitting report failed: \(error.localizedDescription)")
      }
    }
  }
}
