// Vendored from https://github.com/elai950/AlertToast with modifications
import SwiftUI

@MainActor
public extension View {
    func toast(
        isPresenting: Binding<Bool>,
        duration: Double = 2,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0,
        alert: @escaping () -> Toast,
        onTap: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> some View {
        modifier(ToastModifier(
            isPresenting: isPresenting,
            duration: duration,
            tapToDismiss: tapToDismiss,
            offsetY: offsetY,
            alert: alert,
            onTap: onTap,
            completion: completion
        ))
    }
}

@MainActor
public struct ToastModifier: ViewModifier {
    @Binding private var isPresenting: Bool
    @State private var duration: Double
    @State private var tapToDismiss = true
    @State private var workItem: DispatchWorkItem?
    @State private var hostRect: CGRect = .zero
    @State private var alertRect: CGRect = .zero

    let offsetY: CGFloat
    let alert: () -> Toast
    let onTap: (() -> Void)?
    let completion: (() -> Void)?

    public init(
        isPresenting: Binding<Bool>,
        duration: Double = 2,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0,
        alert: @escaping () -> Toast,
        onTap: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        _isPresenting = isPresenting
        _duration = State(initialValue: duration)
        _tapToDismiss = State(initialValue: tapToDismiss)
        self.offsetY = offsetY
        self.alert = alert
        self.onTap = onTap
        self.completion = completion
    }

    private var screen: CGRect {
        UIScreen.main.bounds
    }

    private var offset: CGFloat {
        -hostRect.midY + alertRect.height
    }

    @ViewBuilder
    public func main() -> some View {
        if isPresenting {
            switch alert().displayMode {
            case .alert:
                alert()
                    .onTapGesture {
                        onTap?()
                        if tapToDismiss {
                            withAnimation(.spring) {
                                workItem?.cancel()
                                isPresenting = false
                                workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
            case .hud:
                alert()
                    .overlay(
                        GeometryReader { geo -> AnyView in
                            let rect = geo.frame(in: .global)

                            if rect.integral != alertRect.integral {
                                DispatchQueue.main.async {
                                    alertRect = rect
                                }
                            }
                            return AnyView(EmptyView())
                        }
                    )
                    .onTapGesture {
                        onTap?()
                        if tapToDismiss {
                            withAnimation(.spring) {
                                workItem?.cancel()
                                isPresenting = false
                                workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(.move(edge: .top).combined(with: .opacity))
            case .banner:
                alert()
                    .onTapGesture {
                        onTap?()
                        if tapToDismiss {
                            withAnimation(.spring) {
                                workItem?.cancel()
                                isPresenting = false
                                workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(alert().displayMode == .banner(.slide) ? .slide
                        .combined(with: .opacity) : .move(edge: .bottom))
            }
        }
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        switch alert().displayMode {
        case .banner:
            content
                .overlay(ZStack {
                    main()
                        .offset(y: offsetY)
                }
                .animation(.spring, value: isPresenting))
                .onChange(of: isPresenting) { _, presented in
                    if presented { onAppearAction() }
                }
        case .hud:
            content
                .overlay(
                    GeometryReader { geo -> AnyView in
                        let rect = geo.frame(in: .global)

                        if rect.integral != hostRect.integral {
                            DispatchQueue.main.async {
                                hostRect = rect
                            }
                        }

                        return AnyView(EmptyView())
                    }
                    .overlay(ZStack {
                        main()
                            .offset(y: offsetY)
                    }
                    .frame(maxWidth: screen.width, maxHeight: screen.height)
                    .offset(y: offset)
                    .animation(.spring, value: isPresenting))
                )
                .onChange(of: isPresenting) { _, presented in
                    if presented {
                        onAppearAction()
                    }
                }
        case .alert:
            content
                .overlay(ZStack {
                    main()
                        .offset(y: offsetY)
                }
                .frame(maxWidth: screen.width, maxHeight: screen.height, alignment: .center)
                .edgesIgnoringSafeArea(.all)
                .animation(.spring, value: isPresenting))
                .onChange(of: isPresenting) { _, presented in
                    if presented {
                        onAppearAction()
                    }
                }
        }
    }

    private func onAppearAction() {
        if duration > 0 {
            workItem?.cancel()

            let task = DispatchWorkItem {
                withAnimation(.spring) {
                    isPresenting = false
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}
