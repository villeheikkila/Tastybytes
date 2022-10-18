import SwiftUI

struct ChipView: View {
    let title: String
    let systemName: String? = nil
    var cornerRadius: CGFloat = 15
    

    var body: some View {
        HStack {
            if let systemName = systemName {
                Image(systemName: systemName).font(.title3)
            }
            Text(title).font(.system(size: 10, weight: .bold, design: .default))
        }.padding(.all, 4)
            .foregroundColor(.white)
            .background(Color(.systemBlue))
            .cornerRadius(cornerRadius)
    }
}
