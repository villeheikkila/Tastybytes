import Foundation
public import Tagged

public enum AdminEvent {}

public extension AdminEvent {
    typealias Id = Tagged<AdminEvent, Int>
}
