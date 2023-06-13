import SwiftUI

struct WebShape: Shape {
    // swiftlint:disable function_body_length
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5 * width, y: 0))
        path.addCurve(
            to: CGPoint(x: width, y: 0.5 * height),
            control1: CGPoint(x: 0.77596 * width, y: 0),
            control2: CGPoint(x: width, y: 0.22404 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.5 * width, y: height),
            control1: CGPoint(x: width, y: 0.77596 * height),
            control2: CGPoint(x: 0.77596 * width, y: height)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: 0.5 * height),
            control1: CGPoint(x: 0.22404 * width, y: height),
            control2: CGPoint(x: 0, y: 0.77596 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.5 * width, y: 0),
            control1: CGPoint(x: 0, y: 0.22404 * height),
            control2: CGPoint(x: 0.22404 * width, y: 0)
        )
        path.move(to: CGPoint(x: 0.60654 * width, y: 0.66667 * height))
        path.addLine(to: CGPoint(x: 0.39342 * width, y: 0.66667 * height))
        path.addCurve(
            to: CGPoint(x: 0.5 * width, y: 0.906 * height),
            control1: CGPoint(x: 0.41617 * width, y: 0.76917 * height),
            control2: CGPoint(x: 0.45346 * width, y: 0.83808 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.60654 * width, y: 0.66667 * height),
            control1: CGPoint(x: 0.54975 * width, y: 0.83346 * height),
            control2: CGPoint(x: 0.58504 * width, y: 0.76392 * height)
        )
        path.move(to: CGPoint(x: 0.30833 * width, y: 0.66667 * height))
        path.addLine(to: CGPoint(x: 0.11804 * width, y: 0.66667 * height))
        path.addCurve(
            to: CGPoint(x: 0.3995 * width, y: 0.90483 * height),
            control1: CGPoint(x: 0.16954 * width, y: 0.78437 * height),
            control2: CGPoint(x: 0.27238 * width, y: 0.87383 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.30833 * width, y: 0.66667 * height),
            control1: CGPoint(x: 0.35583 * width, y: 0.83263 * height),
            control2: CGPoint(x: 0.32521 * width, y: 0.75242 * height)
        )
        path.move(to: CGPoint(x: 0.88196 * width, y: 0.66667 * height))
        path.addLine(to: CGPoint(x: 0.69167 * width, y: 0.66667 * height))
        path.addCurve(
            to: CGPoint(x: 0.60104 * width, y: 0.90392 * height),
            control1: CGPoint(x: 0.67538 * width, y: 0.7495 * height),
            control2: CGPoint(x: 0.64604 * width, y: 0.82863 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.88196 * width, y: 0.66667 * height),
            control1: CGPoint(x: 0.72654 * width, y: 0.87212 * height),
            control2: CGPoint(x: 0.83092 * width, y: 0.78329 * height)
        )
        path.move(to: CGPoint(x: 0.29842 * width, y: 0.41667 * height))
        path.addLine(to: CGPoint(x: 0.09167 * width, y: 0.41667 * height))
        path.addCurve(
            to: CGPoint(x: 0.09167 * width, y: 0.58333 * height),
            control1: CGPoint(x: 0.08054 * width, y: 0.47138 * height),
            control2: CGPoint(x: 0.08054 * width, y: 0.52854 * height)
        )
        path.addLine(to: CGPoint(x: 0.29646 * width, y: 0.58333 * height))
        path.addCurve(
            to: CGPoint(x: 0.29842 * width, y: 0.41667 * height),
            control1: CGPoint(x: 0.2915 * width, y: 0.52796 * height),
            control2: CGPoint(x: 0.29225 * width, y: 0.472 * height)
        )
        path.move(to: CGPoint(x: 0.61762 * width, y: 0.41667 * height))
        path.addLine(to: CGPoint(x: 0.38233 * width, y: 0.41667 * height))
        path.addCurve(
            to: CGPoint(x: 0.38012 * width, y: 0.58333 * height),
            control1: CGPoint(x: 0.37546 * width, y: 0.47192 * height),
            control2: CGPoint(x: 0.37462 * width, y: 0.528 * height)
        )
        path.addLine(to: CGPoint(x: 0.61983 * width, y: 0.58333 * height))
        path.addCurve(
            to: CGPoint(x: 0.61762 * width, y: 0.41667 * height),
            control1: CGPoint(x: 0.62538 * width, y: 0.528 * height),
            control2: CGPoint(x: 0.62446 * width, y: 0.47196 * height)
        )
        path.move(to: CGPoint(x: 0.90833 * width, y: 0.41667 * height))
        path.addLine(to: CGPoint(x: 0.70154 * width, y: 0.41667 * height))
        path.addCurve(
            to: CGPoint(x: 0.70354 * width, y: 0.58333 * height),
            control1: CGPoint(x: 0.70771 * width, y: 0.472 * height),
            control2: CGPoint(x: 0.70846 * width, y: 0.52796 * height)
        )
        path.addLine(to: CGPoint(x: 0.90833 * width, y: 0.58333 * height))
        path.addCurve(
            to: CGPoint(x: 0.90833 * width, y: 0.41667 * height),
            control1: CGPoint(x: 0.91917 * width, y: 0.52979 * height),
            control2: CGPoint(x: 0.91971 * width, y: 0.473 * height)
        )
        path.move(to: CGPoint(x: 0.40183 * width, y: 0.09463 * height))
        path.addCurve(
            to: CGPoint(x: 0.11804 * width, y: 0.33333 * height),
            control1: CGPoint(x: 0.27362 * width, y: 0.12513 * height),
            control2: CGPoint(x: 0.16987 * width, y: 0.21488 * height)
        )
        path.addLine(to: CGPoint(x: 0.31192 * width, y: 0.33333 * height))
        path.addCurve(
            to: CGPoint(x: 0.40183 * width, y: 0.09463 * height),
            control1: CGPoint(x: 0.33004 * width, y: 0.24825 * height),
            control2: CGPoint(x: 0.361 * width, y: 0.16729 * height)
        )
        path.move(to: CGPoint(x: 0.49996 * width, y: 0.09262 * height))
        path.addCurve(
            to: CGPoint(x: 0.39733 * width, y: 0.33333 * height),
            control1: CGPoint(x: 0.45458 * width, y: 0.16637 * height),
            control2: CGPoint(x: 0.42037 * width, y: 0.2365 * height)
        )
        path.addLine(to: CGPoint(x: 0.60262 * width, y: 0.33333 * height))
        path.addCurve(
            to: CGPoint(x: 0.49996 * width, y: 0.09262 * height),
            control1: CGPoint(x: 0.58037 * width, y: 0.23975 * height),
            control2: CGPoint(x: 0.54692 * width, y: 0.16883 * height)
        )
        path.move(to: CGPoint(x: 0.59862 * width, y: 0.0955 * height))
        path.addCurve(
            to: CGPoint(x: 0.68804 * width, y: 0.33333 * height),
            control1: CGPoint(x: 0.64083 * width, y: 0.171 * height),
            control2: CGPoint(x: 0.67083 * width, y: 0.25217 * height)
        )
        path.addLine(to: CGPoint(x: 0.88196 * width, y: 0.33333 * height))
        path.addCurve(
            to: CGPoint(x: 0.59862 * width, y: 0.0955 * height),
            control1: CGPoint(x: 0.83062 * width, y: 0.216 * height),
            control2: CGPoint(x: 0.72521 * width, y: 0.12675 * height)
        )
        return path
    }
    // swiftlint:enable function_body_length
}
