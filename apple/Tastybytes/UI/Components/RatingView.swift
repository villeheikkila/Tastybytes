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
        Image(systemName: "star")
          .resizable()
          .foregroundColor(.yellow)
          .overlay(
            GeometryReader { geo in
              let paintedPortion = min(5, max(0, rating - Double(i)))
              let width = geo.size.width * paintedPortion + (paintedPortion > 0.75 ? 8 : 0)
              Image(systemName: "star.fill")
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
      return 10
    case .large:
      return 24
    }
  }
}

struct RatingView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      RatingView(rating: 3.5, type: .small)
      RatingView(rating: 3.5, type: .large)
    }
  }
}
