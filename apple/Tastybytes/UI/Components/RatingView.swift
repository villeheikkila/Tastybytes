import SwiftUI

struct RatingView: View {
  let rating: Double
  let type: StarType

  private let width: Double
  private let height: Double
  private let spacing: Double

  init(rating: Double, type: StarType = .large) {
    self.rating = rating
    self.type = type
    width = type == .small ? 12 : 24
    height = type == .small ? 12 : 24
    spacing = type == .small ? 5 : 10
  }

  var body: some View {
    HStack(spacing: 10) {
      ForEach(0 ... 4, id: \.self) { i in
        Image(systemName: "star")
          .overlay(
            GeometryReader { geo in
              let fraction = rating - Double(i)
              let paintedPortion = min(5, max(0, fraction))
              let width = geo.size.width * paintedPortion + (paintedPortion > 0.75 ? 5 : 0)
              Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .mask(
                  Rectangle()
                    .frame(width: width, height: geo.size.height)
                    .offset(x: -geo.size.width / 4)
                )
            }
          )
          .font(.title)
          .frame(width: width, height: height)
      }
    }
    .accessibilityLabel("\(rating) stars")
  }
}

enum StarType {
  case large, small
}

struct RatingView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      RatingView(rating: 3.5, type: .small)
      RatingView(rating: 3.5, type: .large)
    }
  }
}
