import EnvironmentModels
import SwiftUI

public extension View {
    func toasts(presenting: Binding<ToastEvent?>) -> some View {
        modifier(ToastViewModifier(presenting: presenting))
    }
}

public struct ToastViewModifier: ViewModifier {
    @Binding var presenting: ToastEvent?
    @State private var workItem: DispatchWorkItem?

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay(ZStack {
                if let presenting {
                    Toast(type: presenting)
                        .onTapGesture {
                            if presenting.tapToDismiss {
                                withAnimation(.spring) {
                                    workItem?.cancel()
                                    self.presenting = nil
                                    workItem = nil
                                }
                            }
                        }
                        .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
                        .offset(y: presenting.offsetY)
                }
            }
            .animation(.spring, value: presenting != nil))
            .onChange(of: presenting) { _, presented in
                if let presented {
                    if presented.duration > 0 {
                        workItem?.cancel()

                        let task = DispatchWorkItem {
                            withAnimation(.spring) {
                                presenting = nil
                                workItem = nil
                            }
                        }
                        workItem = task
                        DispatchQueue.main.asyncAfter(deadline: .now() + presented.duration, execute: task)
                    }
                }
            }
    }
}
