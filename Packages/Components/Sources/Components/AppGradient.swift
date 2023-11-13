import SwiftUI

public struct AppGradient: View {
    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        LinearGradient(
            gradient: backgroundGradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var backgroundGradient: Gradient {
        let data = [
            (opacity: 0.0, location: 0.0),
            (opacity: 0.014, location: 0.03),
            (opacity: 0.028, location: 0.06),
            (opacity: 0.042, location: 0.09),
            (opacity: 0.056, location: 0.12),
            (opacity: 0.070, location: 0.15),
            (opacity: 0.084, location: 0.18),
            (opacity: 0.098, location: 0.21),
            (opacity: 0.112, location: 0.24),
            (opacity: 0.126, location: 0.27),
            (opacity: 0.140, location: 0.30),
            (opacity: 0.154, location: 0.33),
            (opacity: 0.168, location: 0.36),
            (opacity: 0.182, location: 0.39),
            (opacity: 0.196, location: 0.42),
            (opacity: 0.210, location: 0.45),
            (opacity: 0.224, location: 0.48),
            (opacity: 0.238, location: 0.51),
            (opacity: 0.252, location: 0.54),
            (opacity: 0.266, location: 0.57),
            (opacity: 0.280, location: 0.60),
            (opacity: 0.294, location: 0.63),
            (opacity: 0.308, location: 0.66),
            (opacity: 0.322, location: 0.69),
            (opacity: 0.336, location: 0.72),
            (opacity: 0.350, location: 0.75),
            (opacity: 0.365, location: 0.78),
            (opacity: 0.380, location: 0.81),
            (opacity: 0.395, location: 0.84),
            (opacity: 0.41, location: 0.87),
            (opacity: 0.425, location: 0.9),
            (opacity: 0.44, location: 0.93),
            (opacity: 0.455, location: 0.96),
            (opacity: 0.46, location: 0.97),
            (opacity: 0.465, location: 0.98),
            (opacity: 0.470, location: 0.99),
            (opacity: 0.475, location: 1.0),
        ]

        let stops = data.map { opacity, location in
            Gradient.Stop(
                color: color.opacity(opacity),
                location: location
            )
        }

        return Gradient(stops: stops)
    }
}
