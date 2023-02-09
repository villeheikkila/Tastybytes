import SwiftUI

struct ChipView: View {
  let title: String
  let systemName: String? = nil
  var cornerRadius: Double = 15

  var body: some View {
    HStack {
      if let systemName {
        Image(systemName: systemName).font(.title3)
      }
      Text(title).font(.system(size: 8, weight: .bold, design: .default))
    }
    .padding(.all, 3)
    .foregroundColor(.white)
    .background(Color(.systemBlue))
    .cornerRadius(cornerRadius)
  }
}
