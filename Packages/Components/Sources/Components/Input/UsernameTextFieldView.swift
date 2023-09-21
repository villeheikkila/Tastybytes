import SwiftUI

public struct UsernameTextFieldView: View {
    @Binding var username: String

    public init(username: Binding<String>) {
        _username = username
    }

    public var body: some View {
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
