import Foundation

public protocol CreationInfo {
    var createdBy: Profile { get }
    var createdAt: Date { get }
}
