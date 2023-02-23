import SwiftUI

struct PasswordTextFieldView: View {
  @Binding var password: String
  @FocusState var focusedField: Field?

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
      .focused($focusedField, equals: .password)
      .modifier(AuthenticationInput())
    }
  }
}
