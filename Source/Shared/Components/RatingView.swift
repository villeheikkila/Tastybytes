import SwiftUI

@MainActor
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

public enum StarType {
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

struct RatingColorKey: EnvironmentKey {
    static var defaultValue: Color = .yellow
}

extension EnvironmentValues {
    var ratingColor: Color {
        get { self[RatingColorKey.self] }
        set { self[RatingColorKey.self] = newValue }
    }
}

extension View {
    func ratingColor(_ color: Color) -> some View {
        environment(\.ratingColor, color)
    }
}

struct RatingSizeKey: EnvironmentKey {
    static var defaultValue: StarType = .large
}

extension EnvironmentValues {
    var ratingSize: StarType {
        get { self[RatingSizeKey.self] }
        set { self[RatingSizeKey.self] = newValue }
    }
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
