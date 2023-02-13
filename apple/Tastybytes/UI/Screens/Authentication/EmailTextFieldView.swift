import SwiftUI

struct EmailTextFieldView: View {
  @Binding var email: String
  @FocusState var focusedField: Field?

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "envelope")
        TextField("Email address", text: $email)
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .modifier(AuthenticationInput())
      .focused($focusedField, equals: .email)
    }
  }
}
