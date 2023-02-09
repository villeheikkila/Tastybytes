import SwiftUI

struct LinkedInShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.79167 * width, y: 0))
    path.addLine(to: CGPoint(x: 0.20833 * width, y: 0))
    path.addCurve(
      to: CGPoint(x: 0, y: 0.20833 * height),
      control1: CGPoint(x: 0.09329 * width, y: 0),
      control2: CGPoint(x: 0, y: 0.09329 * height)
    )
    path.addLine(to: CGPoint(x: 0, y: 0.79167 * height))
    path.addCurve(
      to: CGPoint(x: 0.20833 * width, y: height),
      control1: CGPoint(x: 0, y: 0.90671 * height),
      control2: CGPoint(x: 0.09329 * width, y: height)
    )
    path.addLine(to: CGPoint(x: 0.79167 * width, y: height))
    path.addCurve(
      to: CGPoint(x: width, y: 0.79167 * height),
      control1: CGPoint(x: 0.90675 * width, y: height),
      control2: CGPoint(x: width, y: 0.90671 * height)
    )
    path.addLine(to: CGPoint(x: width, y: 0.20833 * height))
    path.addCurve(
      to: CGPoint(x: 0.79167 * width, y: 0),
      control1: CGPoint(x: width, y: 0.09329 * height),
      control2: CGPoint(x: 0.90675 * width, y: 0)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.33333 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.20833 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.20833 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.33333 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.33333 * width, y: 0.79167 * height))
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.27083 * width, y: 0.2805 * height))
    path.addCurve(
      to: CGPoint(x: 0.19792 * width, y: 0.207 * height),
      control1: CGPoint(x: 0.23058 * width, y: 0.2805 * height),
      control2: CGPoint(x: 0.19792 * width, y: 0.24758 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.27083 * width, y: 0.1335 * height),
      control1: CGPoint(x: 0.19792 * width, y: 0.16642 * height),
      control2: CGPoint(x: 0.23058 * width, y: 0.1335 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.34375 * width, y: 0.207 * height),
      control1: CGPoint(x: 0.31108 * width, y: 0.1335 * height),
      control2: CGPoint(x: 0.34375 * width, y: 0.16642 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.27083 * width, y: 0.2805 * height),
      control1: CGPoint(x: 0.34375 * width, y: 0.24758 * height),
      control2: CGPoint(x: 0.31112 * width, y: 0.2805 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.83333 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.70833 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.70833 * width, y: 0.55817 * height))
    path.addCurve(
      to: CGPoint(x: 0.54167 * width, y: 0.55817 * height),
      control1: CGPoint(x: 0.70833 * width, y: 0.41783 * height),
      control2: CGPoint(x: 0.54167 * width, y: 0.42846 * height)
    )
    path.addLine(to: CGPoint(x: 0.54167 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.41667 * width, y: 0.79167 * height))
    path.addLine(to: CGPoint(x: 0.41667 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.54167 * width, y: 0.33333 * height))
    path.addLine(to: CGPoint(x: 0.54167 * width, y: 0.40688 * height))
    path.addCurve(
      to: CGPoint(x: 0.83333 * width, y: 0.51004 * height),
      control1: CGPoint(x: 0.59983 * width, y: 0.29913 * height),
      control2: CGPoint(x: 0.83333 * width, y: 0.29117 * height)
    )
    path.addLine(to: CGPoint(x: 0.83333 * width, y: 0.79167 * height))
    path.closeSubpath()
    return path
  }
}
