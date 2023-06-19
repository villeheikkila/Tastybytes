import SwiftUI

struct RatingView: View {
    let rating: Double
    let type: StarType

    init(rating: Double, type: StarType = .large) {
        self.rating = rating
        self.type = type
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0 ... 4, id: \.self) { i in
                Image(systemSymbol: .star)
                    .resizable()
                    .foregroundColor(.yellow)
                    .overlay(
                        GeometryReader { geo in
                            let paintedPortion = min(5, max(0, rating - Double(i)))
                            let width = geo.size.width * paintedPortion + (paintedPortion > 0.75 ? 8 : 0)
                            Image(systemSymbol: .starFill)
                                .resizable()
                                .foregroundColor(.yellow)
                                .mask(
                                    Rectangle()
                                        .frame(width: width, height: geo.size.height)
                                        .offset(x: -geo.size.width / 4)
                                )
                        }
                    )
                    .font(.title)
                    .frame(width: type.size, height: type.size)
            }
        }
        .accessibilityLabel("\(rating) stars")
    }
}

enum StarType {
    case large, small

    var size: Double {
        switch self {
        case .small:
            10
        case .large:
            24
        }
    }
}

#Preview {
    VStack {
        RatingView(rating: 3.5, type: .small)
        RatingView(rating: 3.5, type: .large)
    }
}
