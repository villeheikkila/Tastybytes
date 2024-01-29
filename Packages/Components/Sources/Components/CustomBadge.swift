import SwiftUI

struct Badge: View {
    let badgeCount: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(badgeCount.formatted())
                .bold()
                .font(.caption)
                .padding(5)
                .background(.red)
                .foregroundColor(.white)
                .clipShape(Circle())
                .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.6 }
                .alignmentGuide(.top) { $0[.top] + $0.height * 0.4 }
        }
    }
}

public struct BadgeViewModifier: ViewModifier {
    let badgeCount: Int

    public func body(content: Content) -> some View {
        content.overlay(alignment: .topTrailing) {
            if badgeCount != 0 {
                Badge(badgeCount: badgeCount)
            }
        }
    }
}

public extension View {
    func customBadge(_ badgeCount: Int) -> some View {
        modifier(BadgeViewModifier(badgeCount: badgeCount))
    }
}
