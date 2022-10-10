import GoTrue
import SwiftUI

struct ProfileView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            Text(user.jsonFormatted())
                .padding()
        }
    }
}

