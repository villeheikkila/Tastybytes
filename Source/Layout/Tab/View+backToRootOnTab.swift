import SwiftUI

struct BackToRootOnTabViewModifier: ViewModifier {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager

    let tab: Tab

    func body(content: Content) -> some View {
        content
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if self.tab == tab {
                    router.reset()
                }
            }
    }
}

struct ScrollToTopBackToRootOnTabViewModifier: ViewModifier {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @Binding var scrollToTop: Int

    let tab: Tab

    func body(content: Content) -> some View {
        content
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if self.tab == tab {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    } else {
                        router.reset()
                    }
                }
            }
    }
}

extension View {
    func backToRootOnTab(_ tab: Tab) -> some View {
        modifier(BackToRootOnTabViewModifier(tab: tab))
    }
}

extension View {
    func scrollToTopBackToRootOnTab(_ tab: Tab, scrollToTop: Binding<Int>) -> some View {
        modifier(ScrollToTopBackToRootOnTabViewModifier(scrollToTop: scrollToTop, tab: tab))
    }
}
