import Models
import SwiftUI

struct BarcodeManagementRow: View {
    let barcode: ProductBarcode.JoinedWithCreator

    var body: some View {
        HStack {
            Avatar(profile: barcode.profile)
                .avatarSize(.medium)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(barcode.profile.preferredName).font(.caption)
                    Spacer()
                    Text(barcode.createdAt.formatted(.customRelativetime)).font(.caption2)
                }
                Text(barcode.barcode)
                    .font(.callout)
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .listRowBackground(Color.clear)
    }
}
