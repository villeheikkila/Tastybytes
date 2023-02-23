import SwiftUI

struct UsernameTextFieldView: View {
  @Binding var username: String
  @FocusState var focusedField: Field?

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
      .focused($focusedField, equals: .email)
    }
  }
}
