import SwiftUI

struct CompanyPageView: View {
    let company: Company
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Text(company.name)
        }
        .task {
            viewModel.getInitialData(company.id)
        }
    }
}

extension CompanyPageView {
    @MainActor class ViewModel: ObservableObject {
        @Published var company: Company?
        
        func getInitialData(_ companyId: Int) {
            Task {
                let company = try await repository.company.getById(id: companyId)
                DispatchQueue.main.async {
                    self.company = company
                }
            }
        }
    }
}
