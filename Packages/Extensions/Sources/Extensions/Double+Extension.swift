public extension Double? {
    var toRatingString: String {
        String(format: "%.2f", self ?? "")
    }
}
