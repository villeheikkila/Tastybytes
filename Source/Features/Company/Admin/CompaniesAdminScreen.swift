
import Models
import Repositories
import SwiftUI

struct CompaniesAdminScreen: View {
    @Environment(Repository.self) private var repository
    @State private var companies = [Company.Saved]()
    @State private var state: ScreenState = .loading
    @State private var searchTerm = ""

    private var filtered: [Company.Saved] {
        companies.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var body: some View {
        List(filtered) { company in
            RouterLink(open: .sheet(.companyAdmin(id: company.id, onUpdate: { company in
                companies = companies.replacingWithId(company.id, with: .init(company: company))
            }, onDelete: { id in
                companies = companies.removingWithId(id)
            }))) {
                CompanyEntityView(company: company)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .refreshable {
            await initialize()
        }
        .verificationBadgeVisibility(.visible)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .navigationTitle("companiesAdmin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .initialTask {
            await initialize()
        }
    }

    private func initialize() async {
        do {
            companies = try await repository.company.getAll()
            state = .populated
        } catch {
            state = .error(error)
        }
    }
}
