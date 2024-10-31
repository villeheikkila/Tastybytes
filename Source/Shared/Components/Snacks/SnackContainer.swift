import SwiftUI

struct SnackContainer: View {
    @Environment(SnackController.self) private var snackController
    @State private var showOverview: Bool = false

    var body: some View {
        @Bindable var snackController = snackController
        ZStack(alignment: .bottom) {
            if showOverview {
                overlayBackground
            }
            let layout = showOverview ? AnyLayout(VStackLayout(spacing: 12)) : AnyLayout(ZStackLayout())
            layout {
                ForEach($snackController.snacks) { $snack in
                    let index = (snackController.snacks.count - 1) - (snackController.snacks.firstIndex(where: { $0.id == snack.id }) ?? 0)
                    snack.view
                        .offset(x: snack.offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let xOffset = value.translation.width < 0 ? value.translation.width : 0
                                    snack.offsetX = xOffset
                                }.onEnded { value in
                                    let xOffset = value.translation.width + (value.velocity.width / 2)
                                    if -xOffset > 200 {
                                        snackController.remove(snack.id)
                                    } else {
                                        withAnimation(.bouncy) {
                                            snack.offsetX = 0
                                        }
                                    }
                                }
                        )
                        .visualEffect { [showOverview] content, _ in
                            content
                                .scaleEffect(showOverview ? 1 : scale(index), anchor: .bottom)
                                .offset(y: showOverview ? 0 : offsetY(index))
                        }
                        .zIndex(snack.isDeleting ? 1000 : 0)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(insertion: .offset(y: -100), removal: .move(edge: .leading)))
                }
            }
            .onTapGesture {
                showOverview.toggle()
            }
            .padding(.bottom, 15)
        }
        .animation(.bouncy, value: showOverview)
        .onChange(of: snackController.snacks.isEmpty) { _, newValue in
            if newValue {
                showOverview = false
            }
        }
    }

    private var overlayBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
            .onTapGesture {
                showOverview = false
            }
    }

    nonisolated func offsetY(_ index: Int) -> CGFloat {
        let offset = min(CGFloat(index) * 15, 30)
        return -offset
    }

    nonisolated func scale(_ index: Int) -> CGFloat {
        let scale = min(CGFloat(index) * 0.1, 1)
        return 1 - scale
    }
}
