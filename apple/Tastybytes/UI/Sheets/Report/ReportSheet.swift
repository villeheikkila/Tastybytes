import AlertToast
import SwiftUI

struct ReportSheet: View {
  private let logger = getLogger(category: "ReportSheet")
  @EnvironmentObject private var client: AppClient
  @Environment(\.dismiss) private var dismiss
  @State private var reasonText = ""
  @State private var showToast = false

  let entity: Report.Entity

  var body: some View {
    Form {
      Section {
        reportedEntityView
      } header: {
        Text("Content in question")
      }
      Section {
        TextField("Reason", text: $reasonText, axis: .vertical)
          .lineLimit(8, reservesSpace: true)
        ProgressButton("Submit", action: {
          await submitReport(onSubmit: {
            dismiss()
          })
        }).bold()
      } header: {
        Text("Report")
      }
    }
    .navigationTitle("Report \(entity.label)")
    .navigationBarItems(leading: Button("Close", role: .cancel, action: { dismiss() }).bold())
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Report submitted!")
    }
  }

  @ViewBuilder private var reportedEntityView: some View {
    switch entity {
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
      CheckInEntityView(checkIn: checkIn)
    }
  }

  func submitReport(onSubmit _: @escaping () -> Void) async {
    switch await client.report.insert(report: Report.NewRequest(message: reasonText, entity: entity)) {
    case .success:
      showToast = true
    case let .failure(error):
      logger.error("submitting report failed: \(error.localizedDescription)")
    }
  }
}
