import SwiftUI

struct PrivateProfileSign: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "eye.slash.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .accessibility(hidden: true)
                    Text("profile.private.title")
                        .font(.title3)
                }
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}
