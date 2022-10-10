
import Foundation
import SwiftUI
import Supabase

struct SignInView: View {
    @State var presentHomeView: Bool = false
    @State var email = ""
    @State var password = ""
    
    @State var user = User()
    @ViewBuilder
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Log In")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 24)
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                Button {
                    Task {
                        await self.signIn(email: self.email, password: self.password)
                    }
                } label: {
                  
                    Text("Log In")
                        .padding()
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(5)
                }.padding(.top, 20)
            Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 64)
           
        }
        .fullScreenCover(isPresented: self.$presentHomeView) {
            HomeView(user: $user)
        }
    }
    
    func signIn(email: String, password: String) async {
        guard
            let result = try? await API.supabase.auth.signIn(email: email, password: password)
        else {
            return
        }
        
        print(result)
    }
    
    func fetchUserDetails(userID: String, completion: @escaping (_ user: User) -> ())  {
        API.supabase.database.from("User").select().eq(column: "userID", value: userID).execute { result in
            switch result {
            case let .success(response):
                print(response)
                    do {
                        let user = try response.decoded(to: [User].self)
                        completion(user[0])
                        print(user[0])
                    } catch {
                        print(String(describing: error))
                    }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
