struct Permission: Identifiable, Decodable, Hashable, Sendable {
  let id: Int
  let name: PermissionName

  enum CodingKeys: String, CodingKey {
    case id
    case name
  }
}

extension Permission {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "permissions"
    let saved = "id, name"

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
  }
}

enum PermissionName: String, Decodable, Equatable, Sendable {
  case canDeleteProducts = "can_delete_products"
  case canDeleteCompanies = "can_delete_companies"
  case canDeleteBrands = "can_delete_brands"
  case canAddSubcategories = "can_add_subcategories"
  case canEditCompanies = "can_edit_companies"
  case canMergeProducts = "can_merge_products"
  case canEditBrands = "can_edit_brands"
  case canUpdateSubBrands = "can_update_sub_brands"
  case canDeleteFlavors = "can_delete_flavors"
  case canUpdateFlavors = "can_update_flavors"
  case canInsertFlavors = "can_insert_flavors"
  case canCreateCheckIns = "can_create_check_ins"
  case canCreateProducts = "can_create_products"
  case canCreateBrands = "can_create_brands"
  case canSendFriendRequests = "can_send_friend_requests"
  case canReactToCheckIns = "can_react_to_check_ins"
  case canCreateCompanies = "can_create_companies"
  case canVerify = "can_verify"
  case canEditProducts = "can_edit_products"
  case canDeleteLocations = "can_delete_locations"
  case canAddBarcodes = "can_add_barcodes"
  case canDeleteBarcodes = "can_delete_barcodes"
  case canSetCheckInDate = "can_set_check_in_date"
  case canEditSubcategories = "can_edit_subcategories"
  case canEditServingStyles = "can_edit_serving_styles"
  case canDeleteServingStyles = "can_delete_serving_styles"
  case canAddServingStyles = "can_add_serving_styles"
  case canAddCategories = "can_add_categories"
  case canAddCompanyLogo = "can_add_company_logo"
  case canAddBrandLogo = "can_add_brand_logo"
}
