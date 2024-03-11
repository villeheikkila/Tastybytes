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

    let completion: (() -> Void)?

    public init(
        presenting: Binding<ToastEvent?>,
        onTap _: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        _presenting = presenting
        _duration = State(initialValue: presenting.wrappedValue?.duration ?? 2)
        _tapToDismiss = State(initialValue: presenting.wrappedValue?.tapToDismiss ?? true)
        self.completion = completion
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay(ZStack {
                if let presenting {
                    Toast(type: presenting)
                        .onTapGesture {
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
                        .offset(y: -hostRect.midY + alertRect.height)

                }
            }
            .animation(.spring, value: presenting != nil))
            .onChange(of: presenting) { _, presented in
                if presented != nil {
                    onAppearAction()
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
