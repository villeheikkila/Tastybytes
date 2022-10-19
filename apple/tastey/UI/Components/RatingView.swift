import SwiftUI

struct RatingView: View {
    let rating: Double
    
    init(rating: Int) {
        self.rating = Double(rating) / 2
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 5, id: \.self) { pos in
                if pos < Int(rating) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(.yellow))
                        .opacity(1.0)
                } else if Int(rating.rounded(.towardZero)) == pos && rating.truncatingRemainder(dividingBy: 1) == 0.5 {
                    Image(systemName: "star.leadinghalf.filled")
                        .foregroundColor(Color(.yellow))
                        .opacity(1.0)
                } else {
                    Image(systemName: "star")
                        .foregroundColor(Color(.white))
                        .opacity(0.4)
                }
            }
        }
    }
}
