import Models
import SwiftUI

struct CreationInfoSection: View {
    let createdBy: Profile?
    let createdAt: Date?

    var body: some View {
        Section("location.admin.section.creator") {
            if let createdBy {
                RouterLink(open: .screen(.profile(createdBy))) {
                    HStack {
                        Avatar(profile: createdBy)
                        VStack(alignment: .leading) {
                            Text(createdBy.preferredName)
                            if let createdAt {
                                Text(createdAt, format:
                                    .dateTime
                                        .year()
                                        .month(.wide)
                                        .day())
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            } else if let createdAt {
                Text(createdAt, format:
                    .dateTime
                        .year()
                        .month(.wide)
                        .day())
                    .foregroundColor(.secondary)
            }
        }
        .customListRowBackground()
    }
}
