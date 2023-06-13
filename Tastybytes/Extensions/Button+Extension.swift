import SFSafeSymbols
import SwiftUI

typealias ButtonLabelView = Label

extension Button where Label == ButtonLabelView<Text, Image> {
    init(_ titleKey: LocalizedStringKey, systemSymbol: SFSymbol, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action, label: {
            ButtonLabelView(titleKey, systemSymbol: systemSymbol)
        })
    }
}
