import Extensions
import SwiftUI

public struct SparklesView: View {
    public init() {}

    public var body: some View {
        ForEach(0 ..< 8) { _ in
            SparkleView()
        }
    }
}

struct SparkleView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @State private var rotation: CGFloat = 0
    @State private var position = CGPoint.zero
    @State private var direction = false
    @State private var offset = CGFloat.random(in: 10 ... 18) * ([-1, 1].randomElement() ?? -1)

    let sparkle: Sparkle
    let duration = CGFloat.random(in: 1.5 ... 2.5)

    init() {
        sparkle = Sparkle.random()
    }

    var body: some View {
        image
            .rotationEffect(Angle(degrees: rotation))
            .shadow(
                color: sparkle.shadowColor,
                radius: sparkle.size.width * 0.5,
                y: colorScheme == .light ? sparkle.size.height * 0.5 : 0
            )
            .offset(y: direction ? offset : 0)
            .position(position)
            .onReceive(timer) { _ in
                moveSparkles()
            }
            .onAppear {
                timer = Timer.publish(every: duration, on: .current, in: .common).autoconnect()
                position = sparkle.position(screenWidth: UIScreen.main.bounds.width)
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }

    private var image: some View {
        Image(systemName: sparkle.systemName)
            .resizable()
            .scaledToFit()
            .frame(size: sparkle.size)
            .foregroundColor(sparkle.foregroundColor)
            .accessibility(hidden: true)
    }

    private func moveSparkles() {
        withAnimation(.easeInOut(duration: duration)) {
            direction.toggle()
            offset = CGFloat.random(in: 8 ... 16)
            rotation = CGFloat.random(in: -20 ... 20)
        }
    }
}

struct Sparkle {
    let systemName: String
    let foregroundColor: Color
    let shadowColor: Color

    private let sizeRange: (min: CGFloat, max: CGFloat)

    static let sparkle = Sparkle(
        systemName: "sparkle",
        foregroundColor: Color(.sRGB, red: 200 / 255, green: 228 / 255, blue: 238 / 255, opacity: 1),
        shadowColor: Color(
            .sRGB,
            red: (200 / 255) * 0.9,
            green: (228 / 255) * 0.9,
            blue: (238 / 255) * 0.9,
            opacity: 1
        ),
        sizeRange: (10, 25)
    )
    static let bubble = Sparkle(
        systemName: "circle.fill",
        foregroundColor: Color(.sRGB, red: 0.588235, green: 0.705882, blue: 0.921569, opacity: 1),
        shadowColor: Color(.sRGB, red: 200 / 255, green: 228 / 255, blue: 238 / 255, opacity: 1),
        sizeRange: (5, 10)
    )

    static func random() -> Sparkle {
        let sparkles = [Sparkle.sparkle, Sparkle.bubble]
        if let randomSparkle = sparkles.randomElement() {
            return randomSparkle
        }
        return sparkle
    }

    var size: CGSize {
        let height = CGFloat.random(in: sizeRange.min ... sizeRange.max)
        return CGSize(width: height, height: height)
    }

    func position(screenWidth: CGFloat) -> CGPoint {
        let x = CGFloat.random(in: 36 + size.width ... screenWidth - 36 - size.width)
        let y = CGFloat.random(in: -50 + size.height ... 100 - size.height)
        return CGPoint(x: x, y: y)
    }
}
