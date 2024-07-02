import SwiftUI

struct OpenOnTapModifier: ViewModifier {
    @Environment(Router.self) private var router

    let open: Router.Open

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                router.open(open)
            }
            .accessibility(addTraits: .isLink)
    }
}

extension View {
    func openOnTap(_ open: Router.Open) -> some View {
        modifier(OpenOnTapModifier(open: open))
    }
}
