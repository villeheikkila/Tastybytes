import Foundation

public extension DispatchTime {
    func elapsedTime() -> Double {
        let elapsedTime = DispatchTime.now().uptimeNanoseconds - uptimeNanoseconds
        return Double(elapsedTime) / 1_000_000.0
    }
}
