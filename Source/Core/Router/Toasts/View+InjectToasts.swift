import EnvironmentModels
import SwiftUI

public extension View {
    func injectToasts(item: Binding<ToastEvent?>) -> some View {
        modifier(ToastViewModifier(item: item))
    }
}

public struct ToastViewModifier: ViewModifier {
    @Binding var item: ToastEvent?
    @State private var workItem: DispatchWorkItem?

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay(ZStack {
                if let item {
                    ToastView(type: item)
                        .onTapGesture {
                            if item.tapToDismiss {
                                withAnimation(.spring) {
                                    workItem?.cancel()
                                    self.item = nil
                                    workItem = nil
                                }
                            }
                        }
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .offset(y: item.offsetY)
                }
            }
            .animation(.spring, value: item != nil))
            .onChange(of: item) { _, presented in
                if let presented {
                    if presented.duration > 0 {
                        workItem?.cancel()

                        let task = DispatchWorkItem {
                            withAnimation(.spring) {
                                item = nil
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
