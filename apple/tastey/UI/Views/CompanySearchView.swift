import SwiftUI

struct CompanySearchView: View {
    @State var searchText: String = ""
    @State var searchResults = [Company]()

    let onSelect: (_ company: Company) -> Void

    var body: some View {

        NavigationStack {
            List {
                ForEach(searchResults, id: \.id) { company in
                    Button(action: {self.onSelect(company)}) {
                            Text(company.name)
                    }
                }
            }
            .navigationTitle("Search companies")
            .searchable(text: $searchText)
            .onSubmit(of: .search, searchUsers)
            
        }
    }
    
    func searchUsers() {
        Task {
            do {
                let searchResults = try await SupabaseCompanyRepository().search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.searchResults = searchResults
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
