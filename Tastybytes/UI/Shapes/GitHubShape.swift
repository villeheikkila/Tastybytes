import SwiftUI

struct GitHubShape: Shape {
  // swiftlint:disable function_body_length
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.5 * width, y: 0))
    path.addCurve(
      to: CGPoint(x: 0, y: 0.5 * height),
      control1: CGPoint(x: 0.22392 * width, y: 0),
      control2: CGPoint(x: 0, y: 0.22388 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.34196 * width, y: 0.97446 * height),
      control1: CGPoint(x: 0, y: 0.72092 * height),
      control2: CGPoint(x: 0.14325 * width, y: 0.90833 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.375 * width, y: 0.95042 * height),
      control1: CGPoint(x: 0.36692 * width, y: 0.97908 * height),
      control2: CGPoint(x: 0.375 * width, y: 0.96358 * height)
    )
    path.addLine(to: CGPoint(x: 0.375 * width, y: 0.85733 * height))
    path.addCurve(
      to: CGPoint(x: 0.20696 * width, y: 0.79833 * height),
      control1: CGPoint(x: 0.23592 * width, y: 0.88758 * height),
      control2: CGPoint(x: 0.20696 * width, y: 0.79833 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.15142 * width, y: 0.72517 * height),
      control1: CGPoint(x: 0.18421 * width, y: 0.74054 * height),
      control2: CGPoint(x: 0.15142 * width, y: 0.72517 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.15487 * width, y: 0.69479 * height),
      control1: CGPoint(x: 0.10604 * width, y: 0.69412 * height),
      control2: CGPoint(x: 0.15487 * width, y: 0.69479 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.2315 * width, y: 0.74633 * height),
      control1: CGPoint(x: 0.20508 * width, y: 0.69829 * height),
      control2: CGPoint(x: 0.2315 * width, y: 0.74633 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.377 * width, y: 0.78787 * height),
      control1: CGPoint(x: 0.27608 * width, y: 0.82275 * height),
      control2: CGPoint(x: 0.34846 * width, y: 0.80067 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.40875 * width, y: 0.72104 * height),
      control1: CGPoint(x: 0.38146 * width, y: 0.75558 * height),
      control2: CGPoint(x: 0.39442 * width, y: 0.7335 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.18096 * width, y: 0.47392 * height),
      control1: CGPoint(x: 0.29771 * width, y: 0.70833 * height),
      control2: CGPoint(x: 0.18096 * width, y: 0.66546 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.23246 * width, y: 0.33971 * height),
      control1: CGPoint(x: 0.18096 * width, y: 0.41929 * height),
      control2: CGPoint(x: 0.2005 * width, y: 0.37471 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.23733 * width, y: 0.20737 * height),
      control1: CGPoint(x: 0.22729 * width, y: 0.32708 * height),
      control2: CGPoint(x: 0.21017 * width, y: 0.27621 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.37488 * width, y: 0.25862 * height),
      control1: CGPoint(x: 0.23733 * width, y: 0.20737 * height),
      control2: CGPoint(x: 0.27933 * width, y: 0.19396 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: 0.24179 * height),
      control1: CGPoint(x: 0.41475 * width, y: 0.24754 * height),
      control2: CGPoint(x: 0.4575 * width, y: 0.242 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.62525 * width, y: 0.25862 * height),
      control1: CGPoint(x: 0.5425 * width, y: 0.242 * height),
      control2: CGPoint(x: 0.58529 * width, y: 0.24754 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.76262 * width, y: 0.20737 * height),
      control1: CGPoint(x: 0.72071 * width, y: 0.19396 * height),
      control2: CGPoint(x: 0.76262 * width, y: 0.20737 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.76754 * width, y: 0.33971 * height),
      control1: CGPoint(x: 0.78983 * width, y: 0.27625 * height),
      control2: CGPoint(x: 0.77271 * width, y: 0.32712 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.819 * width, y: 0.47392 * height),
      control1: CGPoint(x: 0.79962 * width, y: 0.37471 * height),
      control2: CGPoint(x: 0.819 * width, y: 0.41933 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.59071 * width, y: 0.72062 * height),
      control1: CGPoint(x: 0.819 * width, y: 0.66596 * height),
      control2: CGPoint(x: 0.70204 * width, y: 0.70825 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.625 * width, y: 0.81321 * height),
      control1: CGPoint(x: 0.60862 * width, y: 0.73612 * height),
      control2: CGPoint(x: 0.625 * width, y: 0.76654 * height)
    )
    path.addLine(to: CGPoint(x: 0.625 * width, y: 0.95042 * height))
    path.addCurve(
      to: CGPoint(x: 0.65838 * width, y: 0.97442 * height),
      control1: CGPoint(x: 0.625 * width, y: 0.96371 * height),
      control2: CGPoint(x: 0.633 * width, y: 0.97933 * height)
    )
    path.addCurve(
      to: CGPoint(x: width, y: 0.5 * height),
      control1: CGPoint(x: 0.85692 * width, y: 0.90821 * height),
      control2: CGPoint(x: width, y: 0.72083 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.5 * width, y: 0),
      control1: CGPoint(x: width, y: 0.22388 * height),
      control2: CGPoint(x: 0.77612 * width, y: 0)
    )
    path.closeSubpath()
    return path
  }
  // swiftlint:enable function_body_length
}
