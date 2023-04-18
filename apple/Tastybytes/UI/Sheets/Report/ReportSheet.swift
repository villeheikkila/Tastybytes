import AlertToast
import SwiftUI

struct ReportSheet: View {
  private let logger = getLogger(category: "ReportSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Environment(\.dismiss) private var dismiss
  @State private var reasonText = ""

  let entity: Report.Entity

  var body: some View {
    Form {
      Section {
        reportedEntityView
      } header: {
        Text("Content in question")
      }
      Section("Report") {
        TextField("Reason", text: $reasonText, axis: .vertical)
          .lineLimit(8, reservesSpace: true)
        ProgressButton("Submit", action: {
          await submitReport()
        }).bold()
      }
    }
    .navigationTitle("Report \(entity.label)")
    .navigationBarItems(leading: Button("Close", role: .cancel, action: { dismiss() }).bold())
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

  func submitReport() async {
    switch await repository.report.insert(report: Report.NewRequest(message: reasonText, entity: entity)) {
    case .success:
      dismiss()
      feedbackManager.toggle(.success("Report submitted!"))
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("submitting report failed: \(error.localizedDescription)")
    }
  }
}
