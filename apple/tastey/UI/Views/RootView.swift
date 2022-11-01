import GoTrue
import Supabase
import SwiftUI

struct RootView: View {

    var body: some View {
        UserProviderView(supabaseClient: SupabaseConfig.client) {
            AuthView(supabaseClient: SupabaseConfig.client, loadingContent: ProgressView.init) { session in
                CurrentProfileProviderView(userId: session.user.id) {
                    NavigationStackView()
                }
            }
            
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
