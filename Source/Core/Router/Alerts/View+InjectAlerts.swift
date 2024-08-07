import Extensions
import SwiftUI

struct InjectAlertModifier: ViewModifier {
    @Binding var item: AlertEvent?

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(.error, trigger: item) { _, newValue in
                newValue != nil
            }
            .alert(item: $item) { error in
                error.alert
            }
    }
}

extension View {
    func injectAlerts(item: Binding<AlertEvent?>) -> some View {
        modifier(InjectAlertModifier(item: item))
    }
}
