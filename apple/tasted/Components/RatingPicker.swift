import SwiftUI

struct RatingPicker: View {
    @Binding var rating: Int?

    func image(for number: Int) -> Image {
        if number > rating ?? 0 {
            return Image(systemName: "star")
        } else {
            return Image(systemName: "star.fill")
        }
    }
    
    var body: some View {
        HStack {
            ForEach(1...6, id: \.self) { number in
                image(for: number)
                    .imageScale(.large)
                    .foregroundColor(number > rating ?? 0 ? Color.gray : Color.yellow)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }
}
