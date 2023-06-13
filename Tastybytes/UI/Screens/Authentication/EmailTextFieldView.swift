import SwiftUI

struct EmailTextFieldView: View {
    @Binding var email: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemSymbol: .envelope)
                    .accessibility(hidden: true)
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .modifier(AuthenticationInput())
        }
    }
}
