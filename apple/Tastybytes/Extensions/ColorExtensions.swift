
import SwiftUI

extension Color {
    init(seed: String) {
        var total = 0
        for unicodeScalar in seed.unicodeScalars {
          total += Int(UInt32(unicodeScalar))
        }
        srand48(total * 200)
        let red = Double(drand48())
        srand48(total)
        let green = Double(drand48())
        srand48(total / 200)
        let blue = Double(drand48())
        
        self.init(red: red, green: green, blue: blue)
    }
}
