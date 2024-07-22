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
                                Text(createdAt.formatted())
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            } else if let createdAt {
                Text(createdAt.formatted())
                    .foregroundColor(.secondary)
            }
        }
        .customListRowBackground()
    }
}

struct ModificationInfoView: View {
    let createdBy: Profile?
    let createdAt: Date
    let updatedBy: Profile?
    let updatedAt: Date?

    init(modificationInfo: ModificationInfo) {
        createdAt = modificationInfo.createdAt
        createdBy = modificationInfo.createdBy
        updatedBy = modificationInfo.updatedBy
        updatedAt = modificationInfo.updatedAt
    }

    init(modificationInfo: ModificationInfoCascaded) {
        createdAt = modificationInfo.createdAt
        createdBy = modificationInfo.createdBy
        updatedBy = modificationInfo.updatedBy
        updatedAt = modificationInfo.updatedAt
    }

    var body: some View {
        Section("admin.section.createdBy") {
            if let createdBy {
                RouterLink(open: .screen(.profile(createdBy))) {
                    HStack {
                        Avatar(profile: createdBy)
                        VStack(alignment: .leading) {
                            Text(createdBy.preferredName)
                            Text(createdAt.formatted())
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            } else {
                Text(createdAt.formatted())
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .customListRowBackground()

        if let updatedAt {
            Section("admin.section.updatedBy") {
                if let updatedBy {
                    RouterLink(open: .screen(.profile(updatedBy))) {
                        HStack {
                            Avatar(profile: updatedBy)
                            VStack(alignment: .leading) {
                                Text(updatedBy.preferredName)
                                Text(updatedAt.formatted())
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                } else {
                    Text(updatedAt.formatted())
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .customListRowBackground()
        }
    }
}
