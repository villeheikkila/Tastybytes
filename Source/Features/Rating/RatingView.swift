import SwiftUI

public struct RatingView: View {
    @Environment(\.ratingColor) private var starColor
    @Environment(\.ratingSize) private var starSize
    let rating: Double

    public init(rating: Double) {
        self.rating = rating
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(0 ... 4, id: \.self) { i in
                Image(systemName: "star")
                    .resizable()
                    .foregroundColor(starColor)
                    .overlay(
                        GeometryReader { geo in
                            let paintedPortion = min(5, max(0, rating - Double(i)))
                            let width = geo.size.width * paintedPortion + (paintedPortion > 0.75 ? 8 : 0)
                            Image(systemName: "star.fill")
                                .resizable()
                                .foregroundColor(starColor)
                                .mask(
                                    Rectangle()
                                        .frame(width: width, height: geo.size.height)
                                        .offset(x: -geo.size.width / 4)
                                )
                        }
                    )
                    .font(.title)
                    .frame(width: starSize.size, height: starSize.size)
            }
        }
        .accessibilityLabel("rating.stars \(rating)")
    }
}

public enum StarType: Sendable {
    case large, small

    var size: Double {
        switch self {
        case .small:
            12
        case .large:
            24
        }
    }
}

extension EnvironmentValues {
    @Entry var ratingColor: Color = .yellow
}

extension View {
    func ratingColor(_ color: Color) -> some View {
        environment(\.ratingColor, color)
    }
}

extension EnvironmentValues {
    @Entry var ratingSize: StarType = .large
}

extension View {
    func ratingSize(_ size: StarType) -> some View {
        environment(\.ratingSize, size)
    }
}

#Preview {
    VStack {
        RatingView(rating: 3.5)
            .ratingSize(.small)
        RatingView(rating: 3.5)
            .ratingSize(.large)
    }
}
