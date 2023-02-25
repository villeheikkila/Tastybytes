import SwiftUI

struct PasswordTextFieldView: View {
  @Binding var password: String

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "key")
          .accessibility(hidden: true)
        SecureField("Password", text: $password)
          .textContentType(.password)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .modifier(AuthenticationInput())
    }
  }
}
