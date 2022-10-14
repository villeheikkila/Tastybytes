import SwiftUI

struct ChipView: View {
    let title: String
    let systemName: String? = nil

    var body: some View {
        HStack {
            if let systemName = systemName {
                Image(systemName: systemName).font(.title3)
            }
            Text(title).font(.system(size: 8, weight: .bold, design: .default))
        }.padding(.all, 3)
            .foregroundColor(.white)
            .background(Color(.systemBlue))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemBlue), lineWidth: 1.5)
            )
    }
}
