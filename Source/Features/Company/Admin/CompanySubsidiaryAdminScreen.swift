import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct CompanySubsidiaryAdminScreen: View {
    private let logger = Logger(category: "CompanySubsidiaryScreen")
    @Environment(Repository.self) private var repository
    @State private var companyToAttach: Company.Saved?
    @Binding var company: Company.Detailed

    var body: some View {
        List(company.subsidiaries) { subsidiary in
            RouterLink(open: .screen(.company(subsidiary))) {
                CompanyEntityView(company: subsidiary)
            }
        }
        .toolbar {
            toolbarContent
        }
        .navigationTitle("subsidiaries.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if company.subsidiaries.isEmpty {
                ContentUnavailableView(" subsidaries.empty.title", systemImage: "tray")
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            RouterLink("subsidiaries.pickCompany", systemImage: "plus", open: .sheet(.companyPicker(filterCompanies: company.subsidiaries + [.init(company: company)], onSelect: { company in
                companyToAttach = company
            })))
            .labelStyle(.iconOnly)
            .confirmationDialog("subsidiaries.makeSubsidiaryOf.confirmation.title",
                                isPresented: $companyToAttach.isNotNull(),
                                titleVisibility: .visible,
                                presenting: companyToAttach)
            { presenting in
                AsyncButton(
                    "subsidiaries.makeSubsidiaryOf.confirmation.label \(presenting.name) \(company.name)",
                    action: {
                        await makeCompanySubsidiaryOf(subsidiaryOf: company, presenting)
                    }
                )
            }
        }
    }

    func makeCompanySubsidiaryOf(subsidiaryOf: Company.Detailed, _ company: Company.Saved) async {
        do {
            try await repository.company.makeCompanySubsidiaryOf(id: company.id, subsidiaryOfId: subsidiaryOf.id)
            self.company = subsidiaryOf.copyWith(subsidiaries: subsidiaryOf.subsidiaries + [company])
        } catch {
            logger.error("Failed to make company a subsidiary")
        }
    }
}
