import SwiftUI
import Supabase

struct HomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var user: User
    
    var body: some View {
        VStack {
            Text("Hello,\(user.name ?? "")")
        }
    }
}
