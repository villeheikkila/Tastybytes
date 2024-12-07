import SwiftUI

struct InjectSnacksViewModifier: ViewModifier {
    let alignment: Alignment
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                SnackContainer()
            }
    }
}

extension View {
    func injectSnacks(alignment: Alignment) -> some View {
        modifier(InjectSnacksViewModifier(alignment: alignment))
    }
}

struct SnackContainer: View {
    @Environment(SnackController.self) private var snackController

    var showOverview: Bool {
        snackController.showOverview
    }

    var body: some View {
        ZStack(alignment: showOverview ? .top : .bottom) {
            if showOverview {
                overviewBackground
            }
            let layout = showOverview ? AnyLayout(VStackLayout(spacing: 12)) : AnyLayout(
                ZStackLayout()
            )
            layout {
                SnacksContentView()
            }
        }
        .animation(.bouncy, value: snackController.showOverview)
    }

    private var overviewBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
            .onTapGesture {
                snackController.showOverview = false
            }
    }
}

struct SnacksContentView: View {
    @Environment(SnackController.self) private var snackController

    var showOverview: Bool {
        snackController.showOverview
    }

    var body: some View {
        ForEach(snackController.snacks) { snack in
            let index = (snackController.snacks.count - 1) - (snackController.snacks.firstIndex(where: { $0.id == snack.id }) ?? 0)
            SnackItemView(snack: snack)
                .visualEffect { [showOverview] content, _ in
                    content
                        .scaleEffect(showOverview ? 1 : (1 - min(CGFloat(index) * 0.1, 1)), anchor: .bottom)
                        .offset(y: showOverview ? 0 : -min(-16 + CGFloat(index) * 16, 32))
                }
                .frame(maxWidth: .infinity)
                .transition(.asymmetric(insertion: .offset(y: -128), removal: .move(edge: .leading)))
                .onTapGesture {
                    snackController.showOverview = true
                }
        }
    }
}

struct SnackItemView: View {
    @Environment(SnackController.self) private var snackController
    @State private var offsetX: CGFloat = 0
    let snack: Snack

    var body: some View {
        snack.view
            .zIndex(snack.isDeleting ? 1000 : 0)
            .offset(x: offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offsetX = value.translation.width
                    }
                    .onEnded { value in
                        let xOffset = value.translation.width + (value.velocity.width / 2)
                        if xOffset < -200 {
                            snackController.remove(snack.id)
                        } else {
                            withAnimation(.bouncy) {
                                offsetX = 0
                            }
                        }
                    }
            )
    }
}
