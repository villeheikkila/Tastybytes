import SwiftUI

struct Badge: View {
  let count: Int

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Text(String(count))
        .bold()
        .font(.caption)
        .padding(5)
        .background(Color.red)
        .foregroundColor(.white)
        .clipShape(Circle())
        .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.6 }
        .alignmentGuide(.top) { $0[.top] + $0.height * 0.4 }
    }
  }
}

struct BadgeViewModifier: ViewModifier {
  let count: Int

  func body(content: Content) -> some View {
    content
      // swiftlint:disable empty_count
      .if(count != 0, transform: { view in
        view.overlay(alignment: .topTrailing) {
          Badge(count: count)
        }
      })
  }
}

extension View {
  func customBadge(_ count: Int) -> some View {
    modifier(BadgeViewModifier(count: count))
  }
}
