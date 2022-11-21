import SwiftUI

struct ProfileProductListView: View {
    let profile: Profile
    
    var body: some View {
        List {
            
        }.navigationTitle("Products")
    }
}

extension ProfileProductListView {
    @MainActor class ViewModel: ObservableObject {
    }
}
