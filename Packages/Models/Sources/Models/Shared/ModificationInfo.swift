import Foundation

public protocol ModificationInfo {
    var createdBy: Profile.Saved? { get }
    var createdAt: Date { get }
    var updatedBy: Profile.Saved? { get }
    var updatedAt: Date? { get }
}

public protocol ModificationInfoCascaded {
    var createdBy: Profile.Saved { get }
    var createdAt: Date { get }
    var updatedBy: Profile.Saved? { get }
    var updatedAt: Date? { get }
}
