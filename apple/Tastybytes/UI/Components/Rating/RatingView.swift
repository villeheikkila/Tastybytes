import SwiftUI

struct RatingView: View {
  @State private var starSize: CGSize = .zero
  @State private var controlSize: CGSize = .zero
  @GestureState private var dragging: Bool = false

  let rating: Double
  let type: StarType

  private let width: Double
  private let height: Double

  init(rating: Double, type: StarType = .large) {
    self.rating = rating
    self.type = type
    width = type == .small ? 12 : 24
    height = type == .small ? 12 : 24
  }

  var body: some View {
    HStack(spacing: 3) {
      ForEach(0 ..< Int(rating), id: \.self) { _ in
        Image(systemName: "star.fill")
          .resizable()

          .frame(width: width, height: height)
          .foregroundColor(.yellow)
      }

      if rating != floor(rating) {
        Image(systemName: "star.leadinghalf.fill")
          .resizable()
          .frame(width: width, height: height)
          .foregroundColor(.yellow)
      }

      ForEach(0 ..< Int(Double(5) - rating), id: \.self) { _ in
        Image(systemName: "star")
          .resizable()
          .frame(width: width, height: height)
      }
    }
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
