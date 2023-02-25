import SwiftUI

struct UsernameTextFieldView: View {
  @Binding var username: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "person")
          .accessibility(hidden: true)
        TextField("Username", text: $username)
          .textContentType(.username)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .modifier(AuthenticationInput())
    }
  }
}
