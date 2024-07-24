public extension Permission {
    enum Name: String, Codable, Equatable, Sendable {
        case canDeleteProducts = "can_delete_products"
        case canDeleteCompanies = "can_delete_companies"
        case canDeleteBrands = "can_delete_brands"
        case canAddSubcategories = "can_add_subcategories"
        case canMergeProducts = "can_merge_products"
        case canEditCompanies = "can_edit_companies"
        case canVerify = "can_verify"
        case canEditBrands = "can_edit_brands"
        case canInsertFlavors = "can_insert_flavors"
        case canUpdateFlavors = "can_update_flavors"
        case canDeleteFlavors = "can_delete_flavors"
        case canUpdateSubBrands = "can_update_sub_brands"
        case canCreateCheckIns = "can_create_check_ins"
        case canCreateProducts = "can_create_products"
        case canCreateBrands = "can_create_brands"
        case canSendFriendRequests = "can_send_friend_requests"
        case canReactToCheckIns = "can_react_to_check_ins"
        case canCreateCompanies = "can_create_companies"
        case canEditProducts = "can_edit_products"
        case canDeleteLocations = "can_delete_locations"
        case canDeleteBarcodes = "can_delete_barcodes"
        case canAddBarcodes = "can_add_barcodes"
        case canSetCheckInDate = "can_set_check_in_date"
        case canEditSubcategories = "can_edit_subcategories"
        case canAddServingStyles = "can_add_serving_styles"
        case canDeleteServingStyles = "can_delete_serving_styles"
        case canEditServingStyles = "can_edit_serving_styles"
        case canAddCategories = "can_add_categories"
        case canAddCompanyLogo = "can_add_company_logo"
        case canAddBrandLogo = "can_add_brand_logo"
        case canAddProductLogo = "can_add_product_logo"
        case canReadReports = "can_read_reports"
        case canMergeLocations = "can_merge_locations"
        case canDeleteComments = "can_delete_comments"
        case canDeleteCheckInsAsModerator = "can_delete_check_ins_as_moderator"
        case canDeleteBrandLogo = "can_delete_brand_logo"
        case canDeleteProductLogo = "can_delete_product_logo"
        case canDeleteCompanyLogo = "can_delete_company_logo"
        case canUpdateLocations = "can_update_locations"
        case canDeleteReports = "can_delete_reports"
        case canDeleteSuggestions = "can_delete_suggestions"
        case canDeleteCheckInImages = "can_delete_check_in_images"
        case canDeleteCategory = "can_delete_category"
        case canCommentOnCheckIns = "can_comment_on_check_ins"
    }
}
