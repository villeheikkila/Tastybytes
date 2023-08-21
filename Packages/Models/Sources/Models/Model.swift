import Foundation

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
    withTableName ? "\(tableName) (\(query))" : query
}

extension [String] {
    func joinComma() -> String {
        joined(separator: ", ")
    }
}

extension URL {
    init?(bucketId: String, fileName: String) {
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(fileName)"
        self.init(string: urlString)
    }
}

extension Date {
    init?(timestamptzString: String) {
        let date = CustomDateFormatter.shared.parse(string: timestamptzString, .timestampTz)
        if let date {
            self = date
        } else {
            return nil
        }
    }
}

enum DateParsingError: Error {
    case unsupportedFormat
}

extension Date {
    func customFormat(_ type: CustomDateFormatter.Format) -> String {
        CustomDateFormatter.shared.format(date: self, type)
    }
}

class CustomDateFormatter {
    enum Format {
        case fileNameSuffix, relativeTime, timestampTz, date
    }

    enum ParseFormat {
        case timestampTz, date
    }

    static let shared = CustomDateFormatter()
    private let formatter = DateFormatter()

    func format(date: Date, _ type: Format) -> String {
        switch type {
        case .fileNameSuffix:
            formatter.dateFormat = "yyyy_MM_dd_HH_mm"
            return formatter.string(from: date)
        case .relativeTime:
            let now = Date.now
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
            let minuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: now)
            if let minuteAgo, date > minuteAgo {
                return "Just now"
            } else if let monthAgo, date < monthAgo {
                return date.formatted()
            } else {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .full
                formatter.locale = Locale(identifier: "en_US")
                return formatter.localizedString(for: date, relativeTo: Date.now)
            }
        case .timestampTz:
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: date)
        case .date:
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "d MMM yyyy"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: date)
        }
    }

    func parse(string: String, _ format: ParseFormat) -> Date? {
        switch format {
        case .timestampTz:
            formatter.timeZone = TimeZone(abbreviation: "UTC")

            let formatStrings = [
                "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            ]

            var date: Date?
            for formatString in formatStrings {
                formatter.dateFormat = formatString
                if let parsedDate = formatter.date(from: string) {
                    date = parsedDate
                    break
                }
            }

            return date
        case .date:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: string)
        }
    }
}

extension String? {
    var isNilOrEmpty: Bool {
        // swiftlint:disable empty_string
        self == nil || self == ""
        // swiftlint:enable empty_string
    }
}

extension String? {
    var orEmpty: String {
        self ?? ""
    }
}

extension Array {
    func joinOptionalSpace<T>() -> String where T: ExpressibleByStringLiteral, Element == T? {
        compactMap { $0 as? String }.joined(separator: " ")
    }
}

public enum Database {
    public enum Table: String {
        case brandLikes = "brand_likes"
        case profileWishlistItems = "profile_wishlist_items"
        case products
        case productEditSuggestions = "product_edit_suggestions"
        case profiles
        case checkIns = "check_ins"
        case checkInReactions = "check_in_reactions"
        case companyEditSuggestions = "company_edit_suggestions"
        case locations
        case notifications
        case profilePushNotifications = "profile_push_notifications"
        case brandEditSuggestions = "brand_edit_suggestions"
        case brands
        case categories
        case categoryServingStyles = "category_serving_styles"
        case checkInComments = "check_in_comments"
        case checkInFlavors = "check_in_flavors"
        case checkInTaggedProfiles = "check_in_tagged_profiles"
        case companies
        case countries
        case documents
        case flavors
        case friends
        case permissions
        case productBarcodes = "product_barcodes"
        case productDuplicateSuggestions = "product_duplicate_suggestions"
        case productEditSuggestionSubcategories = "product_edit_suggestion_subcategories"
        case productVariants = "product_variants"
        case productsSubcategories = "products_subcategories"
        case profileSettings = "profile_settings"
        case profilesRoles = "profiles_roles"
        case reports
        case roles
        case rolesPermissions = "roles_permissions"
        case secrets
        case servingStyles = "serving_styles"
        case subBrandEditSuggestion = "sub_brand_edit_suggestion"
        case subBrands = "sub_brands"
        case subcategories

        // views
        case viewCheckInsFromFriends = "view__check_ins_from_friends"
        case viewCheckInsFromCurrentUser = "view__check_ins_from_current_user"
        case viewCheckInsFromFriendsWithoutUnderscore = "view_check_ins_from_friends"
        case viewSearchProductRatings = "view__search_product_ratings"
        case viewProfileProductRatings = "view__profile_product_ratings"
        case viewBrandRatings = "view__brand_ratings"
        case viewCurrentUserFriends = "view__current_user_friends"
        case viewProductRatings = "view__product_ratings"
        case viewRecentLocationsFromCurrentUser = "view__recent_locations_from_current_user"
    }

    public enum Function: String {
        case acceptFriendRequest = "fnc__accept_friend_request"
        case checkIfUsernameIsAvailable = "fnc__check_if_username_is_available"
        case createCheckIn = "fnc__create_check_in"
        case createCheckInReaction = "fnc__create_check_in_reaction"
        case createCompanyEditSuggestion = "fnc__create_company_edit_suggestion"
        case createProduct = "fnc__create_product"
        case createProductEditSuggestion = "fnc__create_product_edit_suggestion"
        case currentUserHasPermission = "fnc__current_user_has_permission"
        case deleteCheckInAsModerator = "fnc__delete_check_in_as_moderator"
        case deleteCheckInCommentAsModerator = "fnc__delete_check_in_comment_as_moderator"
        case deleteCurrentUser = "fnc__delete_current_user"
        case editProduct = "fnc__edit_product"
        case exportData = "fnc__export_data"
        case getActivityFeed = "fnc__get_activity_feed"
        case getCategoryStats = "fnc__get_category_stats"
        case getCompanySummary = "fnc__get_company_summary"
        case getContributionsByUser = "fnc__get_contributions_by_user"
        case getCurrentProfile = "fnc__get_current_profile"
        case getLocationInsertIfNotExist = "fnc__get_location_insert_if_not_exist"
        case getLocationSuggestions = "fnc__get_location_suggestions"
        case getLocationSummary = "fnc__get_location_summary"
        case getProductSummary = "fnc__get_product_summary"
        case getProfileSummary = "fnc__get_profile_summary"
        case getSubcategoryStats = "fnc__get_subcategory_stats"
        case isBrandLikedByCurrentUser = "fnc__is_brand_liked_by_current_user"
        case isOnCurrentUserWishlist = "fnc__is_on_current_user_wishlist"
        case markAllNotificationRead = "fnc__mark_all_notification_read"
        case markCheckInNotificationAsRead = "fnc__mark_check_in_notification_as_read"
        case markFriendRequestNotificationAsRead = "fnc__mark_friend_request_notification_as_read"
        case markNotificationAsRead = "fnc__mark_notification_as_read"
        case mergeLocations = "fnc__merge_locations"
        case mergeProducts = "fnc__merge_products"
        case refreshFirebaseAccessToken = "fnc__refresh_firebase_access_token"
        case searchProducts = "fnc__search_products"
        case searchProfiles = "fnc__search_profiles"
        case softDeleteCheckInReaction = "fnc__soft_delete_check_in_reaction"
        case updateCheckIn = "fnc__update_check_in"
        case upsertPushNotificationToken = "fnc__upsert_push_notification_token"
        case userCanViewCheckIn = "fnc__user_can_view_check_in"
        case userIsFriendsWith = "fnc__user_is_friends_with"
        case verifyBrand = "fnc__verify_brand"
        case verifyCompany = "fnc__verify_company"
        case verifyProduct = "fnc__verify_product"
        case verifySubBrand = "fnc__verify_sub_brand"
        case verifySubcategory = "fnc__verify_subcategory"
    }

    public enum Bucket: String {
        case productLogos = "product-logos"
        case logos
        case checkIns = "check-ins"
        case brandLogos = "brand-logos"
        case avatars
    }
}
