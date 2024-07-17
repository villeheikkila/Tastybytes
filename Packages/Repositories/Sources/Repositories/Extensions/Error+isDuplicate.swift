internal import Supabase

public extension Error {
    var isDuplicate: Bool {
        guard let postgrestError = self as? PostgrestError else {
            return false
        }
        return postgrestError.code == "23505"
    }
}
