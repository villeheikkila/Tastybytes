import SwiftUI

struct FullScreenErrorView: View {
    @State private var task: Task<Void, Never>?

    let title: LocalizedStringKey
    let description: Text?
    let systemImage: String
    let action: () async -> Void

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: description)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                Button(action: onClick, label: {
                    HStack {
                        if task == nil {
                            Text("labels.tryAgain")

                        } else {
                            ProgressView()
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                })
                .allowsHitTesting(task == nil)
                .disabled(task != nil)
                .padding()
                .padding()
            }
            .background(
                AppGradient(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1)),
                alignment: .bottom
            )
            .ignoresSafeArea()
    }

    func onClick() {
        guard task == nil else { return }
        task = Task {
            await action()
            task = nil
        }
    }
}

#Preview {
    FullScreenErrorView(title: "app.error.unexpected.title", description: Text("app.error.unexpected.description"), systemImage: "exclamationmark.triangle", action: {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    })
}
