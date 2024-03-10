import EnvironmentModels

// Vendored from https://github.com/elai950/AlertToast with modifications
import SwiftUI

@MainActor
public extension View {
    func toasts(
        presenting: Binding<ToastEvent?>,
        onTap: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> some View {
        modifier(ToastViewModifier(
            presenting: presenting,
            onTap: onTap,
            completion: completion
        ))
    }
}

@MainActor
public struct ToastViewModifier: ViewModifier {
    @Binding private var presenting: ToastEvent?
    @State private var duration: Double
    @State private var tapToDismiss = true
    @State private var workItem: DispatchWorkItem?
    @State private var hostRect: CGRect = .zero
    @State private var alertRect: CGRect = .zero

    let offsetY: CGFloat
    let onTap: (() -> Void)?
    let completion: (() -> Void)?

    public init(
        presenting: Binding<ToastEvent?>,
        onTap: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        _presenting = presenting
        _duration = State(initialValue: presenting.wrappedValue?.duration ?? 2)
        _tapToDismiss = State(initialValue: presenting.wrappedValue?.tapToDismiss ?? true)
        offsetY = presenting.wrappedValue?.offsetY ?? 0
        self.onTap = onTap
        self.completion = completion
    }

    private var screen: CGRect {
        UIScreen.main.bounds
    }

    private var offset: CGFloat {
        -hostRect.midY + alertRect.height
    }

    private var isPresenting: Bool {
        presenting != nil
    }

    @ViewBuilder
    public func main() -> some View {
        if let presenting {
            switch presenting.displayMode {
            case .alert:
                Toast(type: presenting)
                    .onTapGesture {
                        onTap?()
                        if tapToDismiss {
                            withAnimation(.spring) {
                                workItem?.cancel()
                                self.presenting = nil
                                workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
            case .hud:
                Toast(type: presenting)
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
                                self.presenting = nil
                                workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(.move(edge: .top).combined(with: .opacity))
            case .banner:
                Toast(type: presenting)
                    .onTapGesture {
                        onTap?()
                        if tapToDismiss {
                            withAnimation(.spring) {
                                workItem?.cancel()
                                self.presenting = nil
                                workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(presenting.displayMode == .banner(.slide) ? .slide
                        .combined(with: .opacity) : .move(edge: .bottom))
            }
        }
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        switch presenting?.displayMode ?? .hud {
        case .banner:
            content
                .overlay(ZStack {
                    main()
                        .offset(y: offsetY)
                }
                .animation(.spring, value: presenting != nil))
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
                    presenting = nil
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}
