import { gql } from '@apollo/client';
import * as Apollo from '@apollo/client';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
const defaultOptions = {} as const;
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  BigInt: any;
  Cursor: any;
  Date: any;
  Datetime: any;
  JSON: any;
  Time: any;
  UUID: any;
};

/** Boolean expression comparing fields on type "BigInt" */
export type BigIntFilter = {
  eq?: InputMaybe<Scalars['BigInt']>;
  gt?: InputMaybe<Scalars['BigInt']>;
  gte?: InputMaybe<Scalars['BigInt']>;
  lt?: InputMaybe<Scalars['BigInt']>;
  lte?: InputMaybe<Scalars['BigInt']>;
  neq?: InputMaybe<Scalars['BigInt']>;
};

/** Boolean expression comparing fields on type "Boolean" */
export type BooleanFilter = {
  eq?: InputMaybe<Scalars['Boolean']>;
  gt?: InputMaybe<Scalars['Boolean']>;
  gte?: InputMaybe<Scalars['Boolean']>;
  lt?: InputMaybe<Scalars['Boolean']>;
  lte?: InputMaybe<Scalars['Boolean']>;
  neq?: InputMaybe<Scalars['Boolean']>;
};

/** Boolean expression comparing fields on type "Date" */
export type DateFilter = {
  eq?: InputMaybe<Scalars['Date']>;
  gt?: InputMaybe<Scalars['Date']>;
  gte?: InputMaybe<Scalars['Date']>;
  lt?: InputMaybe<Scalars['Date']>;
  lte?: InputMaybe<Scalars['Date']>;
  neq?: InputMaybe<Scalars['Date']>;
};

/** Boolean expression comparing fields on type "Datetime" */
export type DatetimeFilter = {
  eq?: InputMaybe<Scalars['Datetime']>;
  gt?: InputMaybe<Scalars['Datetime']>;
  gte?: InputMaybe<Scalars['Datetime']>;
  lt?: InputMaybe<Scalars['Datetime']>;
  lte?: InputMaybe<Scalars['Datetime']>;
  neq?: InputMaybe<Scalars['Datetime']>;
};

/** Boolean expression comparing fields on type "Float" */
export type FloatFilter = {
  eq?: InputMaybe<Scalars['Float']>;
  gt?: InputMaybe<Scalars['Float']>;
  gte?: InputMaybe<Scalars['Float']>;
  lt?: InputMaybe<Scalars['Float']>;
  lte?: InputMaybe<Scalars['Float']>;
  neq?: InputMaybe<Scalars['Float']>;
};

/** Boolean expression comparing fields on type "Int" */
export type IntFilter = {
  eq?: InputMaybe<Scalars['Int']>;
  gt?: InputMaybe<Scalars['Int']>;
  gte?: InputMaybe<Scalars['Int']>;
  lt?: InputMaybe<Scalars['Int']>;
  lte?: InputMaybe<Scalars['Int']>;
  neq?: InputMaybe<Scalars['Int']>;
};

/** Boolean expression comparing fields on type "JSON" */
export type JsonFilter = {
  eq?: InputMaybe<Scalars['JSON']>;
  neq?: InputMaybe<Scalars['JSON']>;
};

/** The root type for creating and mutating data */
export type Mutation = {
  __typename?: 'Mutation';
  /** Deletes zero or more records from the collection */
  deleteFrombrandsCollection: BrandsDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromcategoriesCollection: CategoriesDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromcheck_insCollection: Check_InsDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromcompaniesCollection: CompaniesDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromproductsCollection: ProductsDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromprofilesCollection: ProfilesDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromsub_brandsCollection: Sub_BrandsDeleteResponse;
  /** Deletes zero or more records from the collection */
  deleteFromsubcategoriesCollection: SubcategoriesDeleteResponse;
  /** Adds one or more `brandsInsertResponse` records to the collection */
  insertIntobrandsCollection?: Maybe<BrandsInsertResponse>;
  /** Adds one or more `categoriesInsertResponse` records to the collection */
  insertIntocategoriesCollection?: Maybe<CategoriesInsertResponse>;
  /** Adds one or more `check_insInsertResponse` records to the collection */
  insertIntocheck_insCollection?: Maybe<Check_InsInsertResponse>;
  /** Adds one or more `companiesInsertResponse` records to the collection */
  insertIntocompaniesCollection?: Maybe<CompaniesInsertResponse>;
  /** Adds one or more `productsInsertResponse` records to the collection */
  insertIntoproductsCollection?: Maybe<ProductsInsertResponse>;
  /** Adds one or more `profilesInsertResponse` records to the collection */
  insertIntoprofilesCollection?: Maybe<ProfilesInsertResponse>;
  /** Adds one or more `sub_brandsInsertResponse` records to the collection */
  insertIntosub_brandsCollection?: Maybe<Sub_BrandsInsertResponse>;
  /** Adds one or more `subcategoriesInsertResponse` records to the collection */
  insertIntosubcategoriesCollection?: Maybe<SubcategoriesInsertResponse>;
  /** Updates zero or more records in the collection */
  updatebrandsCollection: BrandsUpdateResponse;
  /** Updates zero or more records in the collection */
  updatecategoriesCollection: CategoriesUpdateResponse;
  /** Updates zero or more records in the collection */
  updatecheck_insCollection: Check_InsUpdateResponse;
  /** Updates zero or more records in the collection */
  updatecompaniesCollection: CompaniesUpdateResponse;
  /** Updates zero or more records in the collection */
  updateproductsCollection: ProductsUpdateResponse;
  /** Updates zero or more records in the collection */
  updateprofilesCollection: ProfilesUpdateResponse;
  /** Updates zero or more records in the collection */
  updatesub_brandsCollection: Sub_BrandsUpdateResponse;
  /** Updates zero or more records in the collection */
  updatesubcategoriesCollection: SubcategoriesUpdateResponse;
};


/** The root type for creating and mutating data */
export type MutationDeleteFrombrandsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<BrandsFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromcategoriesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<CategoriesFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromcheck_InsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<Check_InsFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromcompaniesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<CompaniesFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromproductsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<ProductsFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromprofilesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<ProfilesFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromsub_BrandsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<Sub_BrandsFilter>;
};


/** The root type for creating and mutating data */
export type MutationDeleteFromsubcategoriesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<SubcategoriesFilter>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntobrandsCollectionArgs = {
  objects: Array<BrandsInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntocategoriesCollectionArgs = {
  objects: Array<CategoriesInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntocheck_InsCollectionArgs = {
  objects: Array<Check_InsInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntocompaniesCollectionArgs = {
  objects: Array<CompaniesInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntoproductsCollectionArgs = {
  objects: Array<ProductsInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntoprofilesCollectionArgs = {
  objects: Array<ProfilesInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntosub_BrandsCollectionArgs = {
  objects: Array<Sub_BrandsInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationInsertIntosubcategoriesCollectionArgs = {
  objects: Array<SubcategoriesInsertInput>;
};


/** The root type for creating and mutating data */
export type MutationUpdatebrandsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<BrandsFilter>;
  set: BrandsUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdatecategoriesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<CategoriesFilter>;
  set: CategoriesUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdatecheck_InsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<Check_InsFilter>;
  set: Check_InsUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdatecompaniesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<CompaniesFilter>;
  set: CompaniesUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdateproductsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<ProductsFilter>;
  set: ProductsUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdateprofilesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<ProfilesFilter>;
  set: ProfilesUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdatesub_BrandsCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<Sub_BrandsFilter>;
  set: Sub_BrandsUpdateInput;
};


/** The root type for creating and mutating data */
export type MutationUpdatesubcategoriesCollectionArgs = {
  atMost?: Scalars['Int'];
  filter?: InputMaybe<SubcategoriesFilter>;
  set: SubcategoriesUpdateInput;
};

/** Defines a per-field sorting order */
export enum OrderByDirection {
  AscNullsFirst = 'AscNullsFirst',
  AscNullsLast = 'AscNullsLast',
  DescNullsFirst = 'DescNullsFirst',
  DescNullsLast = 'DescNullsLast'
}

export type PageInfo = {
  __typename?: 'PageInfo';
  endCursor?: Maybe<Scalars['String']>;
  hasNextPage: Scalars['Boolean'];
  hasPreviousPage: Scalars['Boolean'];
  startCursor?: Maybe<Scalars['String']>;
};

/** The root type for querying data */
export type Query = {
  __typename?: 'Query';
  /** A pagable collection of type `brands` */
  brandsCollection?: Maybe<BrandsConnection>;
  /** A pagable collection of type `categories` */
  categoriesCollection?: Maybe<CategoriesConnection>;
  /** A pagable collection of type `check_ins` */
  check_insCollection?: Maybe<Check_InsConnection>;
  /** A pagable collection of type `companies` */
  companiesCollection?: Maybe<CompaniesConnection>;
  /** A pagable collection of type `products` */
  productsCollection?: Maybe<ProductsConnection>;
  /** A pagable collection of type `profiles` */
  profilesCollection?: Maybe<ProfilesConnection>;
  /** A pagable collection of type `sub_brands` */
  sub_brandsCollection?: Maybe<Sub_BrandsConnection>;
  /** A pagable collection of type `subcategories` */
  subcategoriesCollection?: Maybe<SubcategoriesConnection>;
};


/** The root type for querying data */
export type QueryBrandsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<BrandsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


/** The root type for querying data */
export type QueryCategoriesCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<CategoriesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CategoriesOrderBy>>;
};


/** The root type for querying data */
export type QueryCheck_InsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<Check_InsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<Check_InsOrderBy>>;
};


/** The root type for querying data */
export type QueryCompaniesCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<CompaniesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};


/** The root type for querying data */
export type QueryProductsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<ProductsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};


/** The root type for querying data */
export type QueryProfilesCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<ProfilesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProfilesOrderBy>>;
};


/** The root type for querying data */
export type QuerySub_BrandsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<Sub_BrandsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<Sub_BrandsOrderBy>>;
};


/** The root type for querying data */
export type QuerySubcategoriesCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<SubcategoriesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<SubcategoriesOrderBy>>;
};

/** Boolean expression comparing fields on type "String" */
export type StringFilter = {
  eq?: InputMaybe<Scalars['String']>;
  gt?: InputMaybe<Scalars['String']>;
  gte?: InputMaybe<Scalars['String']>;
  lt?: InputMaybe<Scalars['String']>;
  lte?: InputMaybe<Scalars['String']>;
  neq?: InputMaybe<Scalars['String']>;
};

/** Boolean expression comparing fields on type "Time" */
export type TimeFilter = {
  eq?: InputMaybe<Scalars['Time']>;
  gt?: InputMaybe<Scalars['Time']>;
  gte?: InputMaybe<Scalars['Time']>;
  lt?: InputMaybe<Scalars['Time']>;
  lte?: InputMaybe<Scalars['Time']>;
  neq?: InputMaybe<Scalars['Time']>;
};

/** Boolean expression comparing fields on type "UUID" */
export type UuidFilter = {
  eq?: InputMaybe<Scalars['UUID']>;
  neq?: InputMaybe<Scalars['UUID']>;
};

export type Brands = {
  __typename?: 'brands';
  brand_owner_id?: Maybe<Scalars['BigInt']>;
  companies?: Maybe<Companies>;
  id: Scalars['BigInt'];
  name: Scalars['String'];
  sub_brandsCollection?: Maybe<Sub_BrandsConnection>;
};


export type BrandsSub_BrandsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<Sub_BrandsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<Sub_BrandsOrderBy>>;
};

export type BrandsConnection = {
  __typename?: 'brandsConnection';
  edges: Array<BrandsEdge>;
  pageInfo: PageInfo;
};

export type BrandsDeleteResponse = {
  __typename?: 'brandsDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Brands>;
};

export type BrandsEdge = {
  __typename?: 'brandsEdge';
  cursor: Scalars['String'];
  node?: Maybe<Brands>;
};

export type BrandsFilter = {
  brand_owner_id?: InputMaybe<BigIntFilter>;
  id?: InputMaybe<BigIntFilter>;
  name?: InputMaybe<StringFilter>;
};

export type BrandsInsertInput = {
  brand_owner_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
};

export type BrandsInsertResponse = {
  __typename?: 'brandsInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Brands>;
};

export type BrandsOrderBy = {
  brand_owner_id?: InputMaybe<OrderByDirection>;
  id?: InputMaybe<OrderByDirection>;
  name?: InputMaybe<OrderByDirection>;
};

export type BrandsUpdateInput = {
  brand_owner_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
};

export type BrandsUpdateResponse = {
  __typename?: 'brandsUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Brands>;
};

export type Categories = {
  __typename?: 'categories';
  id: Scalars['BigInt'];
  name: Scalars['String'];
  subcategoriesCollection?: Maybe<SubcategoriesConnection>;
};


export type CategoriesSubcategoriesCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<SubcategoriesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<SubcategoriesOrderBy>>;
};

export type CategoriesConnection = {
  __typename?: 'categoriesConnection';
  edges: Array<CategoriesEdge>;
  pageInfo: PageInfo;
};

export type CategoriesDeleteResponse = {
  __typename?: 'categoriesDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Categories>;
};

export type CategoriesEdge = {
  __typename?: 'categoriesEdge';
  cursor: Scalars['String'];
  node?: Maybe<Categories>;
};

export type CategoriesFilter = {
  id?: InputMaybe<BigIntFilter>;
  name?: InputMaybe<StringFilter>;
};

export type CategoriesInsertInput = {
  name?: InputMaybe<Scalars['String']>;
};

export type CategoriesInsertResponse = {
  __typename?: 'categoriesInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Categories>;
};

export type CategoriesOrderBy = {
  id?: InputMaybe<OrderByDirection>;
  name?: InputMaybe<OrderByDirection>;
};

export type CategoriesUpdateInput = {
  name?: InputMaybe<Scalars['String']>;
};

export type CategoriesUpdateResponse = {
  __typename?: 'categoriesUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Categories>;
};

export type Check_Ins = {
  __typename?: 'check_ins';
  author_id: Scalars['UUID'];
  check_in_date: Scalars['Datetime'];
  id: Scalars['BigInt'];
  product_id: Scalars['BigInt'];
  products?: Maybe<Products>;
  profiles?: Maybe<Profiles>;
  rating?: Maybe<Scalars['Int']>;
  review?: Maybe<Scalars['String']>;
};

export type Check_InsConnection = {
  __typename?: 'check_insConnection';
  edges: Array<Check_InsEdge>;
  pageInfo: PageInfo;
};

export type Check_InsDeleteResponse = {
  __typename?: 'check_insDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Check_Ins>;
};

export type Check_InsEdge = {
  __typename?: 'check_insEdge';
  cursor: Scalars['String'];
  node?: Maybe<Check_Ins>;
};

export type Check_InsFilter = {
  author_id?: InputMaybe<UuidFilter>;
  check_in_date?: InputMaybe<DatetimeFilter>;
  id?: InputMaybe<BigIntFilter>;
  product_id?: InputMaybe<BigIntFilter>;
  rating?: InputMaybe<IntFilter>;
  review?: InputMaybe<StringFilter>;
};

export type Check_InsInsertInput = {
  author_id?: InputMaybe<Scalars['UUID']>;
  check_in_date?: InputMaybe<Scalars['Datetime']>;
  product_id?: InputMaybe<Scalars['BigInt']>;
  rating?: InputMaybe<Scalars['Int']>;
  review?: InputMaybe<Scalars['String']>;
};

export type Check_InsInsertResponse = {
  __typename?: 'check_insInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Check_Ins>;
};

export type Check_InsOrderBy = {
  author_id?: InputMaybe<OrderByDirection>;
  check_in_date?: InputMaybe<OrderByDirection>;
  id?: InputMaybe<OrderByDirection>;
  product_id?: InputMaybe<OrderByDirection>;
  rating?: InputMaybe<OrderByDirection>;
  review?: InputMaybe<OrderByDirection>;
};

export type Check_InsUpdateInput = {
  author_id?: InputMaybe<Scalars['UUID']>;
  check_in_date?: InputMaybe<Scalars['Datetime']>;
  product_id?: InputMaybe<Scalars['BigInt']>;
  rating?: InputMaybe<Scalars['Int']>;
  review?: InputMaybe<Scalars['String']>;
};

export type Check_InsUpdateResponse = {
  __typename?: 'check_insUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Check_Ins>;
};

export type Companies = {
  __typename?: 'companies';
  brandsCollection?: Maybe<BrandsConnection>;
  id: Scalars['BigInt'];
  name: Scalars['String'];
  productsCollection?: Maybe<ProductsConnection>;
};


export type CompaniesBrandsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<BrandsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


export type CompaniesProductsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<ProductsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

export type CompaniesConnection = {
  __typename?: 'companiesConnection';
  edges: Array<CompaniesEdge>;
  pageInfo: PageInfo;
};

export type CompaniesDeleteResponse = {
  __typename?: 'companiesDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Companies>;
};

export type CompaniesEdge = {
  __typename?: 'companiesEdge';
  cursor: Scalars['String'];
  node?: Maybe<Companies>;
};

export type CompaniesFilter = {
  id?: InputMaybe<BigIntFilter>;
  name?: InputMaybe<StringFilter>;
};

export type CompaniesInsertInput = {
  name?: InputMaybe<Scalars['String']>;
};

export type CompaniesInsertResponse = {
  __typename?: 'companiesInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Companies>;
};

export type CompaniesOrderBy = {
  id?: InputMaybe<OrderByDirection>;
  name?: InputMaybe<OrderByDirection>;
};

export type CompaniesUpdateInput = {
  name?: InputMaybe<Scalars['String']>;
};

export type CompaniesUpdateResponse = {
  __typename?: 'companiesUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Companies>;
};

export type Products = {
  __typename?: 'products';
  check_insCollection?: Maybe<Check_InsConnection>;
  companies?: Maybe<Companies>;
  description?: Maybe<Scalars['String']>;
  id: Scalars['BigInt'];
  manufacturer_id?: Maybe<Scalars['BigInt']>;
  name: Scalars['String'];
  sub_brand_id: Scalars['BigInt'];
  sub_brands?: Maybe<Sub_Brands>;
  subcategories?: Maybe<Subcategories>;
  subcategory_id: Scalars['BigInt'];
};


export type ProductsCheck_InsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<Check_InsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<Check_InsOrderBy>>;
};

export type ProductsConnection = {
  __typename?: 'productsConnection';
  edges: Array<ProductsEdge>;
  pageInfo: PageInfo;
};

export type ProductsDeleteResponse = {
  __typename?: 'productsDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Products>;
};

export type ProductsEdge = {
  __typename?: 'productsEdge';
  cursor: Scalars['String'];
  node?: Maybe<Products>;
};

export type ProductsFilter = {
  description?: InputMaybe<StringFilter>;
  id?: InputMaybe<BigIntFilter>;
  manufacturer_id?: InputMaybe<BigIntFilter>;
  name?: InputMaybe<StringFilter>;
  sub_brand_id?: InputMaybe<BigIntFilter>;
  subcategory_id?: InputMaybe<BigIntFilter>;
};

export type ProductsInsertInput = {
  description?: InputMaybe<Scalars['String']>;
  manufacturer_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
  sub_brand_id?: InputMaybe<Scalars['BigInt']>;
  subcategory_id?: InputMaybe<Scalars['BigInt']>;
};

export type ProductsInsertResponse = {
  __typename?: 'productsInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Products>;
};

export type ProductsOrderBy = {
  description?: InputMaybe<OrderByDirection>;
  id?: InputMaybe<OrderByDirection>;
  manufacturer_id?: InputMaybe<OrderByDirection>;
  name?: InputMaybe<OrderByDirection>;
  sub_brand_id?: InputMaybe<OrderByDirection>;
  subcategory_id?: InputMaybe<OrderByDirection>;
};

export type ProductsUpdateInput = {
  description?: InputMaybe<Scalars['String']>;
  manufacturer_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
  sub_brand_id?: InputMaybe<Scalars['BigInt']>;
  subcategory_id?: InputMaybe<Scalars['BigInt']>;
};

export type ProductsUpdateResponse = {
  __typename?: 'productsUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Products>;
};

export type Profiles = {
  __typename?: 'profiles';
  avatar_url?: Maybe<Scalars['String']>;
  check_insCollection?: Maybe<Check_InsConnection>;
  first_name?: Maybe<Scalars['String']>;
  id: Scalars['UUID'];
  last_name?: Maybe<Scalars['String']>;
  updated_at?: Maybe<Scalars['Datetime']>;
  username: Scalars['String'];
  website?: Maybe<Scalars['String']>;
};


export type ProfilesCheck_InsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<Check_InsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<Check_InsOrderBy>>;
};

export type ProfilesConnection = {
  __typename?: 'profilesConnection';
  edges: Array<ProfilesEdge>;
  pageInfo: PageInfo;
};

export type ProfilesDeleteResponse = {
  __typename?: 'profilesDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Profiles>;
};

export type ProfilesEdge = {
  __typename?: 'profilesEdge';
  cursor: Scalars['String'];
  node?: Maybe<Profiles>;
};

export type ProfilesFilter = {
  avatar_url?: InputMaybe<StringFilter>;
  first_name?: InputMaybe<StringFilter>;
  id?: InputMaybe<UuidFilter>;
  last_name?: InputMaybe<StringFilter>;
  updated_at?: InputMaybe<DatetimeFilter>;
  username?: InputMaybe<StringFilter>;
  website?: InputMaybe<StringFilter>;
};

export type ProfilesInsertInput = {
  avatar_url?: InputMaybe<Scalars['String']>;
  first_name?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['UUID']>;
  last_name?: InputMaybe<Scalars['String']>;
  updated_at?: InputMaybe<Scalars['Datetime']>;
  username?: InputMaybe<Scalars['String']>;
  website?: InputMaybe<Scalars['String']>;
};

export type ProfilesInsertResponse = {
  __typename?: 'profilesInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Profiles>;
};

export type ProfilesOrderBy = {
  avatar_url?: InputMaybe<OrderByDirection>;
  first_name?: InputMaybe<OrderByDirection>;
  id?: InputMaybe<OrderByDirection>;
  last_name?: InputMaybe<OrderByDirection>;
  updated_at?: InputMaybe<OrderByDirection>;
  username?: InputMaybe<OrderByDirection>;
  website?: InputMaybe<OrderByDirection>;
};

export type ProfilesUpdateInput = {
  avatar_url?: InputMaybe<Scalars['String']>;
  first_name?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['UUID']>;
  last_name?: InputMaybe<Scalars['String']>;
  updated_at?: InputMaybe<Scalars['Datetime']>;
  username?: InputMaybe<Scalars['String']>;
  website?: InputMaybe<Scalars['String']>;
};

export type ProfilesUpdateResponse = {
  __typename?: 'profilesUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Profiles>;
};

export type Sub_Brands = {
  __typename?: 'sub_brands';
  brand_id?: Maybe<Scalars['BigInt']>;
  brands?: Maybe<Brands>;
  id: Scalars['BigInt'];
  name: Scalars['String'];
  productsCollection?: Maybe<ProductsConnection>;
};


export type Sub_BrandsProductsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<ProductsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

export type Sub_BrandsConnection = {
  __typename?: 'sub_brandsConnection';
  edges: Array<Sub_BrandsEdge>;
  pageInfo: PageInfo;
};

export type Sub_BrandsDeleteResponse = {
  __typename?: 'sub_brandsDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Sub_Brands>;
};

export type Sub_BrandsEdge = {
  __typename?: 'sub_brandsEdge';
  cursor: Scalars['String'];
  node?: Maybe<Sub_Brands>;
};

export type Sub_BrandsFilter = {
  brand_id?: InputMaybe<BigIntFilter>;
  id?: InputMaybe<BigIntFilter>;
  name?: InputMaybe<StringFilter>;
};

export type Sub_BrandsInsertInput = {
  brand_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
};

export type Sub_BrandsInsertResponse = {
  __typename?: 'sub_brandsInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Sub_Brands>;
};

export type Sub_BrandsOrderBy = {
  brand_id?: InputMaybe<OrderByDirection>;
  id?: InputMaybe<OrderByDirection>;
  name?: InputMaybe<OrderByDirection>;
};

export type Sub_BrandsUpdateInput = {
  brand_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
};

export type Sub_BrandsUpdateResponse = {
  __typename?: 'sub_brandsUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Sub_Brands>;
};

export type Subcategories = {
  __typename?: 'subcategories';
  categories?: Maybe<Categories>;
  category_id: Scalars['BigInt'];
  id: Scalars['BigInt'];
  name: Scalars['String'];
  productsCollection?: Maybe<ProductsConnection>;
};


export type SubcategoriesProductsCollectionArgs = {
  after?: InputMaybe<Scalars['Cursor']>;
  before?: InputMaybe<Scalars['Cursor']>;
  filter?: InputMaybe<ProductsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  last?: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

export type SubcategoriesConnection = {
  __typename?: 'subcategoriesConnection';
  edges: Array<SubcategoriesEdge>;
  pageInfo: PageInfo;
};

export type SubcategoriesDeleteResponse = {
  __typename?: 'subcategoriesDeleteResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Subcategories>;
};

export type SubcategoriesEdge = {
  __typename?: 'subcategoriesEdge';
  cursor: Scalars['String'];
  node?: Maybe<Subcategories>;
};

export type SubcategoriesFilter = {
  category_id?: InputMaybe<BigIntFilter>;
  id?: InputMaybe<BigIntFilter>;
  name?: InputMaybe<StringFilter>;
};

export type SubcategoriesInsertInput = {
  category_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
};

export type SubcategoriesInsertResponse = {
  __typename?: 'subcategoriesInsertResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Subcategories>;
};

export type SubcategoriesOrderBy = {
  category_id?: InputMaybe<OrderByDirection>;
  id?: InputMaybe<OrderByDirection>;
  name?: InputMaybe<OrderByDirection>;
};

export type SubcategoriesUpdateInput = {
  category_id?: InputMaybe<Scalars['BigInt']>;
  name?: InputMaybe<Scalars['String']>;
};

export type SubcategoriesUpdateResponse = {
  __typename?: 'subcategoriesUpdateResponse';
  /** Count of the records impacted by the mutation */
  affectedCount: Scalars['Int'];
  /** Array of records impacted by the mutation */
  records: Array<Subcategories>;
};

export type GetCheckInsQueryVariables = Exact<{
  username: Scalars['String'];
  cursor?: InputMaybe<Scalars['Cursor']>;
}>;


export type GetCheckInsQuery = { __typename?: 'Query', profilesCollection?: { __typename?: 'profilesConnection', edges: Array<{ __typename?: 'profilesEdge', node?: { __typename?: 'profiles', id: any, username: string, check_insCollection?: { __typename?: 'check_insConnection', pageInfo: { __typename?: 'PageInfo', endCursor?: string | null, hasNextPage: boolean }, edges: Array<{ __typename?: 'check_insEdge', node?: { __typename?: 'check_ins', id: any, rating?: number | null, review?: string | null, products?: { __typename?: 'products', id: any, name: string, description?: string | null, companies?: { __typename?: 'companies', id: any, name: string } | null, subcategories?: { __typename?: 'subcategories', id: any, name: string, categories?: { __typename?: 'categories', id: any, name: string } | null } | null, sub_brands?: { __typename?: 'sub_brands', id: any, name: string, brands?: { __typename?: 'brands', id: any, name: string, companies?: { __typename?: 'companies', id: any, name: string } | null } | null } | null } | null } | null }> } | null } | null }> } | null };

export type CheckInNodeFragment = { __typename?: 'check_ins', id: any, rating?: number | null, review?: string | null, products?: { __typename?: 'products', id: any, name: string, description?: string | null, companies?: { __typename?: 'companies', id: any, name: string } | null, subcategories?: { __typename?: 'subcategories', id: any, name: string, categories?: { __typename?: 'categories', id: any, name: string } | null } | null, sub_brands?: { __typename?: 'sub_brands', id: any, name: string, brands?: { __typename?: 'brands', id: any, name: string, companies?: { __typename?: 'companies', id: any, name: string } | null } | null } | null } | null };

export const CheckInNodeFragmentDoc = gql`
    fragment CheckInNode on check_ins {
  id
  rating
  review
  products {
    id
    name
    description
    companies {
      id
      name
    }
    subcategories {
      id
      name
      categories {
        id
        name
      }
    }
    sub_brands {
      id
      name
      brands {
        id
        name
        companies {
          id
          name
        }
      }
    }
  }
}
    `;
export const GetCheckInsDocument = gql`
    query GetCheckIns($username: String!, $cursor: Cursor) {
  profilesCollection(filter: {username: {eq: "villeheikkila"}}) {
    edges {
      node {
        id
        username
        check_insCollection(after: $cursor) {
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              ...CheckInNode
            }
          }
        }
      }
    }
  }
}
    ${CheckInNodeFragmentDoc}`;

/**
 * __useGetCheckInsQuery__
 *
 * To run a query within a React component, call `useGetCheckInsQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetCheckInsQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetCheckInsQuery({
 *   variables: {
 *      username: // value for 'username'
 *      cursor: // value for 'cursor'
 *   },
 * });
 */
export function useGetCheckInsQuery(baseOptions: Apollo.QueryHookOptions<GetCheckInsQuery, GetCheckInsQueryVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useQuery<GetCheckInsQuery, GetCheckInsQueryVariables>(GetCheckInsDocument, options);
      }
export function useGetCheckInsLazyQuery(baseOptions?: Apollo.LazyQueryHookOptions<GetCheckInsQuery, GetCheckInsQueryVariables>) {
          const options = {...defaultOptions, ...baseOptions}
          return Apollo.useLazyQuery<GetCheckInsQuery, GetCheckInsQueryVariables>(GetCheckInsDocument, options);
        }
export type GetCheckInsQueryHookResult = ReturnType<typeof useGetCheckInsQuery>;
export type GetCheckInsLazyQueryHookResult = ReturnType<typeof useGetCheckInsLazyQuery>;
export type GetCheckInsQueryResult = Apollo.QueryResult<GetCheckInsQuery, GetCheckInsQueryVariables>;