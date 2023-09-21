import SwiftUI

public struct PasswordTextFieldView: View {
    public enum Mode {
        case password, newPassword, confirmPassword
    }

    @Binding var password: String
    let mode: Mode

    public init(password: Binding<String>, mode: Mode) {
        _password = password
        self.mode = mode
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "key")
                    .accessibility(hidden: true)
                SecureField(mode == .confirmPassword ? "Confirm Password" : "Password", text: $password)
                    .textContentType(mode == .password ? .password : .newPassword)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .modifier(AuthenticationInput())
        }
    }
}
