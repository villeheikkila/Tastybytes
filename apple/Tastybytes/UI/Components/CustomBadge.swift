import SwiftUI

struct Badge: View {
  let badgeCount: Int

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Text(String(badgeCount))
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

struct BadgeViewModifier: ViewModifier {
  let badgeCount: Int

  func body(content: Content) -> some View {
    content
      .if(badgeCount != 0, transform: { view in
        view.overlay(alignment: .topTrailing) {
          Badge(badgeCount: badgeCount)
        }
      })
  }
}

extension View {
  func customBadge(_ badgeCount: Int) -> some View {
    modifier(BadgeViewModifier(badgeCount: badgeCount))
  }
}
