import SwiftUI

struct ChipView: View {
  let title: String
  let systemName: String? = nil

  var body: some View {
    HStack {
      if let systemName {
        Image(systemName: systemName).font(.title3)
      }
      Text(title).font(.caption2).bold()
    }
    .padding(.all, 2)
    .foregroundColor(.white)
    .background(Color(.systemBlue))
    .cornerRadius(5)
  }
}
