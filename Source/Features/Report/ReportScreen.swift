import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ReportScreen: View {
    private let logger = Logger(category: "ReportScreen")
    @Environment(Repository.self) private var repository
    @State private var alertError: AlertError?
    @State private var reports = [Report]()

    var body: some View {
        List(reports) { report in
            ReportScreenRow(report: report, deleteReport: deleteReport, resolveReport: resolveReport)
        }
        .listStyle(.plain)
        .refreshable {
            await loadInitialData()
        }
        .navigationTitle("report.admin.navigationTitle")
        .alertError($alertError)
        .initialTask {
            await loadInitialData()
        }
    }

    func loadInitialData() async {
        switch await repository.report.getAll() {
        case let .success(reports):
            withAnimation {
                self.reports = reports
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Loading reports failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteReport(_ report: Report) async {
        switch await repository.report.delete(id: report.id) {
        case .success:
            withAnimation {
                reports = reports.removing(report)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func resolveReport(_ report: Report) async {
        switch await repository.report.resolve(id: report.id) {
        case .success:
            withAnimation {
                reports = reports.removing(report)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to resolve report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
struct ReportScreenRow: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var showDeleteConfirmation = false
    let report: Report

    let deleteReport: (_ report: Report) async -> Void
    let resolveReport: (_ report: Report) async -> Void

    private func action() {
        guard let entity = report.entity else { return }
        switch entity {
        case let .brand(brand):
            router.navigate(screen: .brand(brand))
        case let .product(product):
            router.navigate(screen: .product(product))
        case let .company(company):
            router.navigate(screen: .company(company))
        case let .subBrand(subBrand):
            router.fetchAndNavigateTo(repository, .brand(id: subBrand.brand.id))
        case let .checkIn(checkIn):
            router.navigate(screen: .checkIn(checkIn))
        case let .comment(comment):
            router.fetchAndNavigateTo(repository, .company(id: comment.id))
        case let .checkInImage(imageEntity):
            router.fetchAndNavigateTo(repository, .checkIn(id: imageEntity.checkIn.id))
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Avatar(profile: report.createdBy)
                        .avatarSize(.medium)
                    Text(report.createdBy.preferredName)
                        .font(.caption).bold()
                        .foregroundColor(.primary)
                    Spacer()
                    Text(report.createdAt.formatted(.customRelativetime))
                        .font(.caption)
                }

                if let entity = report.entity {
                    VStack(alignment: .leading, spacing: 2) {
                        entity.view
                    }
                }
                if let message = report.message {
                    VStack(alignment: .leading) {
                        Text("report.section.report.title").bold()
                        Text(message).font(.callout)
                    }
                }
            }
        }
        .swipeActions {
            ProgressButton("report.admin.resolve.label", systemImage: "checkmark", action: {
                await resolveReport(report)
            })
            ProgressButton(
                "labels.delete",
                systemImage: "trash",
                role: .destructive,
                action: { await deleteReport(report) }
            )
        }
    }
}
