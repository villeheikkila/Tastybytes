import SwiftUI

struct OnboardingContinueButtonModifier: ViewModifier {
    let title: String
    let isDisabled: Bool
    let onClick: () -> Void

    init(title: String, isDisabled: Bool = false, onClick: @escaping () -> Void) {
        self.title = title
        self.isDisabled = isDisabled
        self.onClick = onClick
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            VStack {
                Spacer()
                Button(action: {
                    onClick()
                }, label: {
                    Spacer()
                    Text(title)
                    Spacer()
                })
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .disabled(isDisabled)
                .cornerRadius(10)
                .padding()
                .padding(.bottom, 10)
            }
        }
    }
}
