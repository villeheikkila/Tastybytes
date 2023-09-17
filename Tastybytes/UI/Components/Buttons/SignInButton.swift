import SwiftUI

struct SignInButton: View {
    enum SignInButtonStyle {
        case password, magicLink

        var text: String {
            switch self {
            case .magicLink:
                "Continue with Magic Link"
            case .password:
                "Continue with Password"
            }
        }

        var systemName: String {
            switch self {
            case .magicLink:
                "envelope.fill"
            case .password:
                "key.fill"
            }
        }

        var color: Color {
            switch self {
            case .magicLink:
                .blue
            case .password:
                .green
            }
        }
    }

    let type: SignInButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: { action() }, label: {
            HStack(spacing: 6) {
                Image(systemName: type.systemName)
                    .imageScale(.small)
                Text(type.text)
                    .fontWeight(.semibold)
                    .scaledToFill()
                    .minimumScaleFactor(0.44)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
            )
        })
    }
}

#Preview {
    SignInButton(type: .password, action: {})
}
