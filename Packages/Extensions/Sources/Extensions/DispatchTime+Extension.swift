import Foundation

public extension DispatchTime {
    func elapsedTime() -> Int {
        let elapsedTime = DispatchTime.now().uptimeNanoseconds - uptimeNanoseconds
        let milliseconds = Double(elapsedTime) / 1_000_000.0
        return Int(round(milliseconds))
    }
}
