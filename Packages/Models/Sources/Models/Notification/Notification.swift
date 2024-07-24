import Foundation
public import Tagged

public enum Notification {}

public extension Notification {
    typealias Id = Tagged<Notification, Int>
}
