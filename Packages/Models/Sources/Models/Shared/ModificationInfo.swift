import Foundation

public protocol ModificationInfo {
    var createdBy: Profile? { get }
    var createdAt: Date { get }
    var updatedBy: Profile? { get }
    var updatedAt: Date? { get }
}

public protocol ModificationInfoCascaded {
    var createdBy: Profile { get }
    var createdAt: Date { get }
    var updatedBy: Profile? { get }
    var updatedAt: Date? { get }
}
