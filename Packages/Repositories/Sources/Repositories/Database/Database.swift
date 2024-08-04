import Foundation
import Models

enum Database {
    enum Table: String {
        case adminEvents = "admin_events"
        case appConfigs = "app_configs"
        case brandLikes = "brand_likes"
        case profileWishlistItems = "profile_wishlist_items"
        case products
        case productLogos = "product_logos"
        case productEditSuggestions = "product_edit_suggestions"
        case profiles
        case profileAvatars = "profile_avatars"
        case checkIns = "check_ins"
        case checkInReactions = "check_in_reactions"
        case companyEditSuggestions = "company_edit_suggestions"
        case locations
        case notifications
        case profilePushNotifications = "profile_push_notifications"
        case brandEditSuggestions = "brand_edit_suggestions"
        case brands
        case brandLogos = "brand_logos"
        case categories
        case categoryServingStyles = "category_serving_styles"
        case checkInImages = "check_in_images"
        case checkInComments = "check_in_comments"
        case checkInTaggedProfiles = "check_in_tagged_profiles"
        case companies
        case companyLogos = "company_logos"
        case countries
        case documents
        case flavors
        case friends
        case permissions
        case productBarcodes = "product_barcodes"
        case productEditSuggestionSubcategories = "product_edit_suggestion_subcategories"
        case productVariants = "product_variants"
        case productsSubcategories = "products_subcategories"
        case profileSettings = "profile_settings"
        case profilesRoles = "profiles_roles"
        case reports
        case roles
        case rolesPermissions = "roles_permissions"
        case servingStyles = "serving_styles"
        case subBrandEditSuggestion = "sub_brand_edit_suggestions"
        case subBrands = "sub_brands"
        case subcategories
        case subscriptionGroups = "subscription_groups"
        case subscriptionProducts = "subscription_products"
        case subscriptionTransactions = "subscription_transactions"
        // views
        case viewActivityFeed = "view__activity_feed"
        case viewCheckInsFromFriends = "view__check_ins_from_friends"
        case viewCheckInsFromCurrentUser = "view__check_ins_from_current_user"
        case viewProfileProductRatings = "view__profile_product_ratings"
        case viewBrandRatings = "view__brand_ratings"
        case viewCurrentUserFriends = "view__current_user_friends"
        case viewProductRatings = "view__product_ratings"
        case viewRecentLocationsFromCurrentUser = "view__recent_locations_from_current_user"
        case viewRecentPurchaseLocationsFromCurrentUser = "view__recent_purchase_locations_from_current_user"
        case viewProfileFriends = "view__profile_friends"
    }

    enum Function: String {
        case acceptFriendRequest = "fnc__accept_friend_request"
        case checkIfUsernameIsAvailable = "fnc__check_if_username_is_available"
        case createCheckIn = "fnc__create_check_in"
        case createCheckInReaction = "fnc__create_check_in_reaction"
        case createProduct = "fnc__create_product"
        case createProductEditSuggestion = "fnc__create_product_edit_suggestion"
        case currentUserHasPermission = "fnc__current_user_has_permission"
        case deleteCheckInAsModerator = "fnc__delete_check_in_as_moderator"
        case deleteCheckInCommentAsModerator = "fnc__delete_check_in_comment_as_moderator"
        case deleteCurrentUser = "fnc__delete_current_user"
        case editProduct = "fnc__edit_product"
        case exportData = "fnc__export_data"
        case getCategoryStats = "fnc__get_category_stats"
        case getCompanySummary = "fnc__get_company_summary"
        case getCurrentProfile = "fnc__get_current_profile"
        case getLocationInsertIfNotExist = "fnc__get_location_insert_if_not_exist"
        case getLocationSuggestions = "fnc__get_location_suggestions"
        case getLocationSummary = "fnc__get_location_summary"
        case updateLocation = "fnc__update_location"
        case getProductSummary = "fnc__get_product_summary"
        case getProfileSummary = "fnc__get_profile_summary"
        case getSubcategoryStats = "fnc__get_subcategory_stats"
        case getTimePeriodStatistics = "fnc__get_time_period_statistics"
        case isBrandLikedByCurrentUser = "fnc__is_brand_liked_by_current_user"
        case isOnCurrentUserWishlist = "fnc__is_on_current_user_wishlist"
        case markAllNotificationRead = "fnc__mark_all_notification_read"
        case markCheckInNotificationAsRead = "fnc__mark_check_in_notification_as_read"
        case markFriendRequestNotificationAsRead = "fnc__mark_friend_request_notification_as_read"
        case markNotificationAsRead = "fnc__mark_notification_as_read"
        case mergeLocations = "fnc__merge_locations"
        case mergeProducts = "fnc__merge_products"
        case searchProducts = "fnc__search_products"
        case softDeleteCheckInReaction = "fnc__soft_delete_check_in_reaction"
        case updateCheckIn = "fnc__update_check_in"
        case upsertDeviceToken = "fnc__upsert_device_token"
        case userCanViewCheckIn = "fnc__user_can_view_check_in"
        case userIsFriendsWith = "fnc__user_is_friends_with"
        case verifyBrand = "fnc__verify_brand"
        case verifyCompany = "fnc__verify_company"
        case verifyProduct = "fnc__verify_product"
        case verifySubBrand = "fnc__verify_sub_brand"
        case verifySubcategory = "fnc__verify_subcategory"
        case updateCheckInImageBlurHash = "fnc__update_check_in_image_blur_hash"
        case getNumberOfCheckInsByDay = "fnc__get_check_ins_by_time_range"
        case getNumberOfCheckInsByLocation = "fnc__get_number_of_check_ins_by_location"
        case deleteUserAsSuperAdmin = "fnc__delete_user_as_super_admin"
        case markAdminEventAsReviewed = "fnc__mark_admin_event_as_reviewed"
        case mergeCompanies = "fnc__merge_companies"
        case getPaginatedCheckIns = "fnc__get_paginated_check_ins"
        case getPaginatedProductRatings = "fnc__get_paginated_product_ratings"
        case updateNotificationSettings = "fnc__update_notification_settings"
        case brandProductsWithRatingCheckInStatus = "fnc__brand_products_with_rating_check_in_status"
        case brandsWithProductCount = "fnc__brands_with_product_count"
    }
}

protocol Queryable {
    associatedtype QueryType

    static func getQuery(_ queryType: QueryType) -> String
}

extension Queryable {
    static func buildQuery(_ tableName: Database.Table, _ query: [String], _ withTableName: Bool) -> String {
        withTableName ? "\(tableName.rawValue) (\(query.joinQueryParts()))" : query.joinQueryParts()
    }

    static func buildQuery(name: String, foreignKey: String, _ query: [String]) -> String {
        "\(name):\(foreignKey) (\(query.joinQueryParts()))"
    }

    static var modificationInfoFragment: String {
        "created_at, updated_at, \(buildQuery(name: "created_by", foreignKey: "created_by", [Profile.getQuery(.minimal(false))])), \(buildQuery(name: "updated_by", foreignKey: "updated_by", [Profile.getQuery(.minimal(false))]))"
    }
}

private extension [String] {
    func joinQueryParts() -> String {
        joined(separator: ", ")
    }
}
