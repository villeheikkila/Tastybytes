import { GraphQLClient } from 'graphql-request';
import * as Dom from 'graphql-request/dist/types.dom';
import gql from 'graphql-tag';
export type Maybe<T> = T;
export type InputMaybe<T> = T;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  /** A location in a connection that can be used for resuming pagination. */
  Cursor: any;
  /** The day, does not include a time. */
  Date: any;
  /**
   * A point in time as described by the [ISO
   * 8601](https://en.wikipedia.org/wiki/ISO_8601) standard. May or may not include a timezone.
   */
  Datetime: any;
  LongText: any;
  MediumText: any;
  ShortText: any;
  /** A universally unique identifier as defined by [RFC 4122](https://tools.ietf.org/html/rfc4122). */
  UUID: any;
};

/** A filter to be used against Boolean fields. All fields are combined with a logical ‘and.’ */
export type BooleanFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['Boolean']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['Boolean']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['Boolean']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['Boolean']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['Boolean']>>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['Boolean']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['Boolean']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['Boolean']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['Boolean']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['Boolean']>>;
};

export type Brand = Node & {
  __typename?: 'Brand';
  /** Reads a single `Company` that is related to this `Brand`. */
  company: Maybe<Company>;
  companyId: Maybe<Scalars['Int']>;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  id: Scalars['Int'];
  name: Maybe<Scalars['MediumText']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Product`. */
  products: ProductsConnection;
  updatedAt: Scalars['Datetime'];
  updatedBy: Maybe<Scalars['UUID']>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByUpdatedBy: Maybe<User>;
};


export type BrandProductsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** A condition to be used against `Brand` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type BrandCondition = {
  /** Checks for equality with the object’s `companyId` field. */
  companyId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `createdBy` field. */
  createdBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['MediumText']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `updatedBy` field. */
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** A filter to be used against `Brand` object types. All fields are combined with a logical ‘and.’ */
export type BrandFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<BrandFilter>>;
  /** Filter by the object’s `companyId` field. */
  companyId: InputMaybe<IntFilter>;
  /** Filter by the object’s `createdAt` field. */
  createdAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `createdBy` field. */
  createdBy: InputMaybe<UuidFilter>;
  /** Filter by the object’s `id` field. */
  id: InputMaybe<IntFilter>;
  /** Filter by the object’s `name` field. */
  name: InputMaybe<MediumTextFilter>;
  /** Negates the expression. */
  not: InputMaybe<BrandFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<BrandFilter>>;
  /** Filter by the object’s `updatedAt` field. */
  updatedAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `updatedBy` field. */
  updatedBy: InputMaybe<UuidFilter>;
};

/** An input for mutations affecting `Brand` */
export type BrandInput = {
  companyId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  name: InputMaybe<Scalars['MediumText']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** Represents an update to a `Brand`. Fields that are set will be updated. */
export type BrandPatch = {
  companyId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  name: InputMaybe<Scalars['MediumText']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `Brand` values. */
export type BrandsConnection = {
  __typename?: 'BrandsConnection';
  /** A list of edges which contains the `Brand` and cursor to aid in pagination. */
  edges: Array<BrandsEdge>;
  /** A list of `Brand` objects. */
  nodes: Array<Maybe<Brand>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Brand` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Brand` edge in the connection. */
export type BrandsEdge = {
  __typename?: 'BrandsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Brand` at the end of the edge. */
  node: Maybe<Brand>;
};

/** Methods to use when ordering `Brand`. */
export enum BrandsOrderBy {
  CompanyIdAsc = 'COMPANY_ID_ASC',
  CompanyIdDesc = 'COMPANY_ID_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  CreatedByAsc = 'CREATED_BY_ASC',
  CreatedByDesc = 'CREATED_BY_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  NameAsc = 'NAME_ASC',
  NameDesc = 'NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UpdatedByAsc = 'UPDATED_BY_ASC',
  UpdatedByDesc = 'UPDATED_BY_DESC'
}

/** A connection to a list of `Category` values. */
export type CategoriesConnection = {
  __typename?: 'CategoriesConnection';
  /** A list of edges which contains the `Category` and cursor to aid in pagination. */
  edges: Array<CategoriesEdge>;
  /** A list of `Category` objects. */
  nodes: Array<Maybe<Category>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Category` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Category` edge in the connection. */
export type CategoriesEdge = {
  __typename?: 'CategoriesEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Category` at the end of the edge. */
  node: Maybe<Category>;
};

/** Methods to use when ordering `Category`. */
export enum CategoriesOrderBy {
  NameAsc = 'NAME_ASC',
  NameDesc = 'NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

export type Category = Node & {
  __typename?: 'Category';
  name: Scalars['String'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Type`. */
  typesByCategory: TypesConnection;
};


export type CategoryTypesByCategoryArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<TypeCondition>;
  filter: InputMaybe<TypeFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<TypesOrderBy>>;
};

/**
 * A condition to be used against `Category` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type CategoryCondition = {
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['String']>;
};

/** A filter to be used against `Category` object types. All fields are combined with a logical ‘and.’ */
export type CategoryFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<CategoryFilter>>;
  /** Filter by the object’s `name` field. */
  name: InputMaybe<StringFilter>;
  /** Negates the expression. */
  not: InputMaybe<CategoryFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<CategoryFilter>>;
};

/** An input for mutations affecting `Category` */
export type CategoryInput = {
  name: Scalars['String'];
};

/** Represents an update to a `Category`. Fields that are set will be updated. */
export type CategoryPatch = {
  name: InputMaybe<Scalars['String']>;
};

export type CheckIn = Node & {
  __typename?: 'CheckIn';
  /** Reads a single `User` that is related to this `CheckIn`. */
  author: Maybe<User>;
  authorId: Scalars['UUID'];
  checkInDate: Maybe<Scalars['Date']>;
  createdAt: Scalars['Datetime'];
  id: Scalars['Int'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `Product` that is related to this `CheckIn`. */
  product: Maybe<Product>;
  productId: Scalars['Int'];
  rating: Maybe<Scalars['Int']>;
  review: Maybe<Scalars['String']>;
  updatedAt: Scalars['Datetime'];
};

/** A condition to be used against `CheckIn` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type CheckInCondition = {
  /** Checks for equality with the object’s `authorId` field. */
  authorId: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `checkInDate` field. */
  checkInDate: InputMaybe<Scalars['Date']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `productId` field. */
  productId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `rating` field. */
  rating: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `review` field. */
  review: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
};

/** A filter to be used against `CheckIn` object types. All fields are combined with a logical ‘and.’ */
export type CheckInFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<CheckInFilter>>;
  /** Filter by the object’s `authorId` field. */
  authorId: InputMaybe<UuidFilter>;
  /** Filter by the object’s `checkInDate` field. */
  checkInDate: InputMaybe<DateFilter>;
  /** Filter by the object’s `createdAt` field. */
  createdAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `id` field. */
  id: InputMaybe<IntFilter>;
  /** Negates the expression. */
  not: InputMaybe<CheckInFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<CheckInFilter>>;
  /** Filter by the object’s `productId` field. */
  productId: InputMaybe<IntFilter>;
  /** Filter by the object’s `rating` field. */
  rating: InputMaybe<IntFilter>;
  /** Filter by the object’s `review` field. */
  review: InputMaybe<StringFilter>;
  /** Filter by the object’s `updatedAt` field. */
  updatedAt: InputMaybe<DatetimeFilter>;
};

/** An input for mutations affecting `CheckIn` */
export type CheckInInput = {
  authorId: Scalars['UUID'];
  checkInDate: InputMaybe<Scalars['Date']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['Int']>;
  productId: Scalars['Int'];
  rating: InputMaybe<Scalars['Int']>;
  review: InputMaybe<Scalars['String']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
};

/** Represents an update to a `CheckIn`. Fields that are set will be updated. */
export type CheckInPatch = {
  authorId: InputMaybe<Scalars['UUID']>;
  checkInDate: InputMaybe<Scalars['Date']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['Int']>;
  productId: InputMaybe<Scalars['Int']>;
  rating: InputMaybe<Scalars['Int']>;
  review: InputMaybe<Scalars['String']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
};

/** A connection to a list of `CheckIn` values. */
export type CheckInsConnection = {
  __typename?: 'CheckInsConnection';
  /** A list of edges which contains the `CheckIn` and cursor to aid in pagination. */
  edges: Array<CheckInsEdge>;
  /** A list of `CheckIn` objects. */
  nodes: Array<Maybe<CheckIn>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CheckIn` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CheckIn` edge in the connection. */
export type CheckInsEdge = {
  __typename?: 'CheckInsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CheckIn` at the end of the edge. */
  node: Maybe<CheckIn>;
};

/** Methods to use when ordering `CheckIn`. */
export enum CheckInsOrderBy {
  AuthorIdAsc = 'AUTHOR_ID_ASC',
  AuthorIdDesc = 'AUTHOR_ID_DESC',
  CheckInDateAsc = 'CHECK_IN_DATE_ASC',
  CheckInDateDesc = 'CHECK_IN_DATE_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  ProductIdAsc = 'PRODUCT_ID_ASC',
  ProductIdDesc = 'PRODUCT_ID_DESC',
  RatingAsc = 'RATING_ASC',
  RatingDesc = 'RATING_DESC',
  ReviewAsc = 'REVIEW_ASC',
  ReviewDesc = 'REVIEW_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC'
}

/** A connection to a list of `Company` values. */
export type CompaniesConnection = {
  __typename?: 'CompaniesConnection';
  /** A list of edges which contains the `Company` and cursor to aid in pagination. */
  edges: Array<CompaniesEdge>;
  /** A list of `Company` objects. */
  nodes: Array<Maybe<Company>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Company` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Company` edge in the connection. */
export type CompaniesEdge = {
  __typename?: 'CompaniesEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Company` at the end of the edge. */
  node: Maybe<Company>;
};

/** Methods to use when ordering `Company`. */
export enum CompaniesOrderBy {
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  CreatedByAsc = 'CREATED_BY_ASC',
  CreatedByDesc = 'CREATED_BY_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsVerifiedAsc = 'IS_VERIFIED_ASC',
  IsVerifiedDesc = 'IS_VERIFIED_DESC',
  NameAsc = 'NAME_ASC',
  NameDesc = 'NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

export type Company = Node & {
  __typename?: 'Company';
  averageRating: Maybe<Scalars['Int']>;
  /** Reads and enables pagination through a set of `Brand`. */
  brands: BrandsConnection;
  checkInsPastMonth: Maybe<Scalars['Int']>;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  id: Scalars['Int'];
  isVerified: Scalars['Boolean'];
  name: Maybe<Scalars['MediumText']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Product`. */
  productsByManufacturerId: ProductsConnection;
  totalCheckIns: Maybe<Scalars['Int']>;
  totalItems: Maybe<Scalars['Int']>;
  /** Reads a single `User` that is related to this `Company`. */
  userByCreatedBy: Maybe<User>;
};


export type CompanyBrandsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  filter: InputMaybe<BrandFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


export type CompanyProductsByManufacturerIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** A condition to be used against `Company` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type CompanyCondition = {
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `createdBy` field. */
  createdBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['MediumText']>;
};

/** A filter to be used against `Company` object types. All fields are combined with a logical ‘and.’ */
export type CompanyFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<CompanyFilter>>;
  /** Filter by the object’s `averageRating` field. */
  averageRating: InputMaybe<IntFilter>;
  /** Filter by the object’s `checkInsPastMonth` field. */
  checkInsPastMonth: InputMaybe<IntFilter>;
  /** Filter by the object’s `createdAt` field. */
  createdAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `createdBy` field. */
  createdBy: InputMaybe<UuidFilter>;
  /** Filter by the object’s `id` field. */
  id: InputMaybe<IntFilter>;
  /** Filter by the object’s `isVerified` field. */
  isVerified: InputMaybe<BooleanFilter>;
  /** Filter by the object’s `name` field. */
  name: InputMaybe<MediumTextFilter>;
  /** Negates the expression. */
  not: InputMaybe<CompanyFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<CompanyFilter>>;
  /** Filter by the object’s `totalCheckIns` field. */
  totalCheckIns: InputMaybe<IntFilter>;
  /** Filter by the object’s `totalItems` field. */
  totalItems: InputMaybe<IntFilter>;
};

/** An input for mutations affecting `Company` */
export type CompanyInput = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['MediumText']>;
};

/** Represents an update to a `Company`. Fields that are set will be updated. */
export type CompanyPatch = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['MediumText']>;
};

/** All input for the create `Brand` mutation. */
export type CreateBrandInput = {
  /** The `Brand` to be created by this mutation. */
  brand: BrandInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `Brand` mutation. */
export type CreateBrandPayload = {
  __typename?: 'CreateBrandPayload';
  /** The `Brand` that was created by this mutation. */
  brand: Maybe<Brand>;
  /** An edge for our `Brand`. May be used by Relay 1. */
  brandEdge: Maybe<BrandsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `Brand`. */
  company: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our create `Brand` mutation. */
export type CreateBrandPayloadBrandEdgeArgs = {
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};

/** All input for the create `Category` mutation. */
export type CreateCategoryInput = {
  /** The `Category` to be created by this mutation. */
  category: CategoryInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `Category` mutation. */
export type CreateCategoryPayload = {
  __typename?: 'CreateCategoryPayload';
  /** The `Category` that was created by this mutation. */
  category: Maybe<Category>;
  /** An edge for our `Category`. May be used by Relay 1. */
  categoryEdge: Maybe<CategoriesEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our create `Category` mutation. */
export type CreateCategoryPayloadCategoryEdgeArgs = {
  orderBy?: InputMaybe<Array<CategoriesOrderBy>>;
};

/** All input for the create `CheckIn` mutation. */
export type CreateCheckInInput = {
  /** The `CheckIn` to be created by this mutation. */
  checkIn: CheckInInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `CheckIn` mutation. */
export type CreateCheckInPayload = {
  __typename?: 'CreateCheckInPayload';
  /** Reads a single `User` that is related to this `CheckIn`. */
  author: Maybe<User>;
  /** The `CheckIn` that was created by this mutation. */
  checkIn: Maybe<CheckIn>;
  /** An edge for our `CheckIn`. May be used by Relay 1. */
  checkInEdge: Maybe<CheckInsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Product` that is related to this `CheckIn`. */
  product: Maybe<Product>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our create `CheckIn` mutation. */
export type CreateCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the create `Company` mutation. */
export type CreateCompanyInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `Company` to be created by this mutation. */
  company: CompanyInput;
};

/** The output of our create `Company` mutation. */
export type CreateCompanyPayload = {
  __typename?: 'CreateCompanyPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Company` that was created by this mutation. */
  company: Maybe<Company>;
  /** An edge for our `Company`. May be used by Relay 1. */
  companyEdge: Maybe<CompaniesEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Company`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our create `Company` mutation. */
export type CreateCompanyPayloadCompanyEdgeArgs = {
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};

/** All input for the create `Product` mutation. */
export type CreateProductInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `Product` to be created by this mutation. */
  product: ProductInput;
};

/** The output of our create `Product` mutation. */
export type CreateProductPayload = {
  __typename?: 'CreateProductPayload';
  /** Reads a single `Brand` that is related to this `Product`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `Product`. */
  manufacturer: Maybe<Company>;
  /** The `Product` that was created by this mutation. */
  product: Maybe<Product>;
  /** An edge for our `Product`. May be used by Relay 1. */
  productEdge: Maybe<ProductsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `Product`. */
  type: Maybe<Type>;
  /** Reads a single `User` that is related to this `Product`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Product`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our create `Product` mutation. */
export type CreateProductPayloadProductEdgeArgs = {
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** All input for the create `Type` mutation. */
export type CreateTypeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `Type` to be created by this mutation. */
  type: TypeInput;
};

/** The output of our create `Type` mutation. */
export type CreateTypePayload = {
  __typename?: 'CreateTypePayload';
  /** Reads a single `Category` that is related to this `Type`. */
  categoryByCategory: Maybe<Category>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `Type` that was created by this mutation. */
  type: Maybe<Type>;
  /** An edge for our `Type`. May be used by Relay 1. */
  typeEdge: Maybe<TypesEdge>;
};


/** The output of our create `Type` mutation. */
export type CreateTypePayloadTypeEdgeArgs = {
  orderBy?: InputMaybe<Array<TypesOrderBy>>;
};

/** All input for the create `User` mutation. */
export type CreateUserInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `User` to be created by this mutation. */
  user: UserInput;
};

/** The output of our create `User` mutation. */
export type CreateUserPayload = {
  __typename?: 'CreateUserPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `User` that was created by this mutation. */
  user: Maybe<User>;
  /** An edge for our `User`. May be used by Relay 1. */
  userEdge: Maybe<UsersEdge>;
};


/** The output of our create `User` mutation. */
export type CreateUserPayloadUserEdgeArgs = {
  orderBy?: InputMaybe<Array<UsersOrderBy>>;
};

/** A filter to be used against Date fields. All fields are combined with a logical ‘and.’ */
export type DateFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['Date']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['Date']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['Date']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['Date']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['Date']>>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['Date']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['Date']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['Date']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['Date']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['Date']>>;
};

/** A filter to be used against Datetime fields. All fields are combined with a logical ‘and.’ */
export type DatetimeFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['Datetime']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['Datetime']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['Datetime']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['Datetime']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['Datetime']>>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['Datetime']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['Datetime']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['Datetime']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['Datetime']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['Datetime']>>;
};

/** All input for the `deleteBrandByCompanyIdAndName` mutation. */
export type DeleteBrandByCompanyIdAndNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  companyId: Scalars['Int'];
  name: Scalars['MediumText'];
};

/** All input for the `deleteBrandByNameAndCompanyId` mutation. */
export type DeleteBrandByNameAndCompanyIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  companyId: Scalars['Int'];
  name: Scalars['MediumText'];
};

/** All input for the `deleteBrandByNodeId` mutation. */
export type DeleteBrandByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Brand` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteBrand` mutation. */
export type DeleteBrandInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `Brand` mutation. */
export type DeleteBrandPayload = {
  __typename?: 'DeleteBrandPayload';
  /** The `Brand` that was deleted by this mutation. */
  brand: Maybe<Brand>;
  /** An edge for our `Brand`. May be used by Relay 1. */
  brandEdge: Maybe<BrandsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `Brand`. */
  company: Maybe<Company>;
  deletedBrandNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our delete `Brand` mutation. */
export type DeleteBrandPayloadBrandEdgeArgs = {
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};

/** All input for the `deleteCategoryByNodeId` mutation. */
export type DeleteCategoryByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Category` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCategory` mutation. */
export type DeleteCategoryInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
};

/** The output of our delete `Category` mutation. */
export type DeleteCategoryPayload = {
  __typename?: 'DeleteCategoryPayload';
  /** The `Category` that was deleted by this mutation. */
  category: Maybe<Category>;
  /** An edge for our `Category`. May be used by Relay 1. */
  categoryEdge: Maybe<CategoriesEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedCategoryNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our delete `Category` mutation. */
export type DeleteCategoryPayloadCategoryEdgeArgs = {
  orderBy?: InputMaybe<Array<CategoriesOrderBy>>;
};

/** All input for the `deleteCheckInByNodeId` mutation. */
export type DeleteCheckInByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckIn` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCheckIn` mutation. */
export type DeleteCheckInInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `CheckIn` mutation. */
export type DeleteCheckInPayload = {
  __typename?: 'DeleteCheckInPayload';
  /** Reads a single `User` that is related to this `CheckIn`. */
  author: Maybe<User>;
  /** The `CheckIn` that was deleted by this mutation. */
  checkIn: Maybe<CheckIn>;
  /** An edge for our `CheckIn`. May be used by Relay 1. */
  checkInEdge: Maybe<CheckInsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedCheckInNodeId: Maybe<Scalars['ID']>;
  /** Reads a single `Product` that is related to this `CheckIn`. */
  product: Maybe<Product>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our delete `CheckIn` mutation. */
export type DeleteCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the `deleteCompanyByName` mutation. */
export type DeleteCompanyByNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['MediumText'];
};

/** All input for the `deleteCompanyByNodeId` mutation. */
export type DeleteCompanyByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Company` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCompany` mutation. */
export type DeleteCompanyInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `Company` mutation. */
export type DeleteCompanyPayload = {
  __typename?: 'DeleteCompanyPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Company` that was deleted by this mutation. */
  company: Maybe<Company>;
  /** An edge for our `Company`. May be used by Relay 1. */
  companyEdge: Maybe<CompaniesEdge>;
  deletedCompanyNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Company`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our delete `Company` mutation. */
export type DeleteCompanyPayloadCompanyEdgeArgs = {
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};

/** All input for the `deleteProductByNameAndBrandIdAndTypeId` mutation. */
export type DeleteProductByNameAndBrandIdAndTypeIdInput = {
  brandId: Scalars['Int'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['MediumText'];
  typeId: Scalars['Int'];
};

/** All input for the `deleteProductByNodeId` mutation. */
export type DeleteProductByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Product` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteProduct` mutation. */
export type DeleteProductInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `Product` mutation. */
export type DeleteProductPayload = {
  __typename?: 'DeleteProductPayload';
  /** Reads a single `Brand` that is related to this `Product`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedProductNodeId: Maybe<Scalars['ID']>;
  /** Reads a single `Company` that is related to this `Product`. */
  manufacturer: Maybe<Company>;
  /** The `Product` that was deleted by this mutation. */
  product: Maybe<Product>;
  /** An edge for our `Product`. May be used by Relay 1. */
  productEdge: Maybe<ProductsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `Product`. */
  type: Maybe<Type>;
  /** Reads a single `User` that is related to this `Product`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Product`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our delete `Product` mutation. */
export type DeleteProductPayloadProductEdgeArgs = {
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** All input for the `deleteTypeByNameAndCategory` mutation. */
export type DeleteTypeByNameAndCategoryInput = {
  category: Scalars['String'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
};

/** All input for the `deleteTypeByNodeId` mutation. */
export type DeleteTypeByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Type` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteType` mutation. */
export type DeleteTypeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `Type` mutation. */
export type DeleteTypePayload = {
  __typename?: 'DeleteTypePayload';
  /** Reads a single `Category` that is related to this `Type`. */
  categoryByCategory: Maybe<Category>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedTypeNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `Type` that was deleted by this mutation. */
  type: Maybe<Type>;
  /** An edge for our `Type`. May be used by Relay 1. */
  typeEdge: Maybe<TypesEdge>;
};


/** The output of our delete `Type` mutation. */
export type DeleteTypePayloadTypeEdgeArgs = {
  orderBy?: InputMaybe<Array<TypesOrderBy>>;
};

/** All input for the `deleteUserByNodeId` mutation. */
export type DeleteUserByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `User` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteUserByUsername` mutation. */
export type DeleteUserByUsernameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  username: Scalars['String'];
};

/** All input for the `deleteUser` mutation. */
export type DeleteUserInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
};

/** The output of our delete `User` mutation. */
export type DeleteUserPayload = {
  __typename?: 'DeleteUserPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedUserNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `User` that was deleted by this mutation. */
  user: Maybe<User>;
  /** An edge for our `User`. May be used by Relay 1. */
  userEdge: Maybe<UsersEdge>;
};


/** The output of our delete `User` mutation. */
export type DeleteUserPayloadUserEdgeArgs = {
  orderBy?: InputMaybe<Array<UsersOrderBy>>;
};

/** A filter to be used against Int fields. All fields are combined with a logical ‘and.’ */
export type IntFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['Int']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['Int']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['Int']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['Int']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['Int']>>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['Int']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['Int']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['Int']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['Int']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['Int']>>;
};

/** All input for the `login` mutation. */
export type LoginInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  password: Scalars['String'];
  username: Scalars['String'];
};

/** The output of our `login` mutation. */
export type LoginPayload = {
  __typename?: 'LoginPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  user: Maybe<User>;
  /** An edge for our `User`. May be used by Relay 1. */
  userEdge: Maybe<UsersEdge>;
};


/** The output of our `login` mutation. */
export type LoginPayloadUserEdgeArgs = {
  orderBy?: InputMaybe<Array<UsersOrderBy>>;
};

/** A filter to be used against LongText fields. All fields are combined with a logical ‘and.’ */
export type LongTextFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['LongText']>;
  /** Not equal to the specified value, treating null like an ordinary value (case-insensitive). */
  distinctFromInsensitive: InputMaybe<Scalars['LongText']>;
  /** Ends with the specified string (case-sensitive). */
  endsWith: InputMaybe<Scalars['LongText']>;
  /** Ends with the specified string (case-insensitive). */
  endsWithInsensitive: InputMaybe<Scalars['LongText']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['LongText']>;
  /** Equal to the specified value (case-insensitive). */
  equalToInsensitive: InputMaybe<Scalars['LongText']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['LongText']>;
  /** Greater than the specified value (case-insensitive). */
  greaterThanInsensitive: InputMaybe<Scalars['LongText']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['LongText']>;
  /** Greater than or equal to the specified value (case-insensitive). */
  greaterThanOrEqualToInsensitive: InputMaybe<Scalars['LongText']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['LongText']>>;
  /** Included in the specified list (case-insensitive). */
  inInsensitive: InputMaybe<Array<Scalars['LongText']>>;
  /** Contains the specified string (case-sensitive). */
  includes: InputMaybe<Scalars['LongText']>;
  /** Contains the specified string (case-insensitive). */
  includesInsensitive: InputMaybe<Scalars['LongText']>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['LongText']>;
  /** Less than the specified value (case-insensitive). */
  lessThanInsensitive: InputMaybe<Scalars['LongText']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['LongText']>;
  /** Less than or equal to the specified value (case-insensitive). */
  lessThanOrEqualToInsensitive: InputMaybe<Scalars['LongText']>;
  /** Matches the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  like: InputMaybe<Scalars['LongText']>;
  /** Matches the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  likeInsensitive: InputMaybe<Scalars['LongText']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['LongText']>;
  /** Equal to the specified value, treating null like an ordinary value (case-insensitive). */
  notDistinctFromInsensitive: InputMaybe<Scalars['LongText']>;
  /** Does not end with the specified string (case-sensitive). */
  notEndsWith: InputMaybe<Scalars['LongText']>;
  /** Does not end with the specified string (case-insensitive). */
  notEndsWithInsensitive: InputMaybe<Scalars['LongText']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['LongText']>;
  /** Not equal to the specified value (case-insensitive). */
  notEqualToInsensitive: InputMaybe<Scalars['LongText']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['LongText']>>;
  /** Not included in the specified list (case-insensitive). */
  notInInsensitive: InputMaybe<Array<Scalars['LongText']>>;
  /** Does not contain the specified string (case-sensitive). */
  notIncludes: InputMaybe<Scalars['LongText']>;
  /** Does not contain the specified string (case-insensitive). */
  notIncludesInsensitive: InputMaybe<Scalars['LongText']>;
  /** Does not match the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLike: InputMaybe<Scalars['LongText']>;
  /** Does not match the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLikeInsensitive: InputMaybe<Scalars['LongText']>;
  /** Does not start with the specified string (case-sensitive). */
  notStartsWith: InputMaybe<Scalars['LongText']>;
  /** Does not start with the specified string (case-insensitive). */
  notStartsWithInsensitive: InputMaybe<Scalars['LongText']>;
  /** Starts with the specified string (case-sensitive). */
  startsWith: InputMaybe<Scalars['LongText']>;
  /** Starts with the specified string (case-insensitive). */
  startsWithInsensitive: InputMaybe<Scalars['LongText']>;
};

/** A filter to be used against MediumText fields. All fields are combined with a logical ‘and.’ */
export type MediumTextFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['MediumText']>;
  /** Not equal to the specified value, treating null like an ordinary value (case-insensitive). */
  distinctFromInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Ends with the specified string (case-sensitive). */
  endsWith: InputMaybe<Scalars['MediumText']>;
  /** Ends with the specified string (case-insensitive). */
  endsWithInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['MediumText']>;
  /** Equal to the specified value (case-insensitive). */
  equalToInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['MediumText']>;
  /** Greater than the specified value (case-insensitive). */
  greaterThanInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['MediumText']>;
  /** Greater than or equal to the specified value (case-insensitive). */
  greaterThanOrEqualToInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['MediumText']>>;
  /** Included in the specified list (case-insensitive). */
  inInsensitive: InputMaybe<Array<Scalars['MediumText']>>;
  /** Contains the specified string (case-sensitive). */
  includes: InputMaybe<Scalars['MediumText']>;
  /** Contains the specified string (case-insensitive). */
  includesInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['MediumText']>;
  /** Less than the specified value (case-insensitive). */
  lessThanInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['MediumText']>;
  /** Less than or equal to the specified value (case-insensitive). */
  lessThanOrEqualToInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Matches the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  like: InputMaybe<Scalars['MediumText']>;
  /** Matches the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  likeInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['MediumText']>;
  /** Equal to the specified value, treating null like an ordinary value (case-insensitive). */
  notDistinctFromInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Does not end with the specified string (case-sensitive). */
  notEndsWith: InputMaybe<Scalars['MediumText']>;
  /** Does not end with the specified string (case-insensitive). */
  notEndsWithInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['MediumText']>;
  /** Not equal to the specified value (case-insensitive). */
  notEqualToInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['MediumText']>>;
  /** Not included in the specified list (case-insensitive). */
  notInInsensitive: InputMaybe<Array<Scalars['MediumText']>>;
  /** Does not contain the specified string (case-sensitive). */
  notIncludes: InputMaybe<Scalars['MediumText']>;
  /** Does not contain the specified string (case-insensitive). */
  notIncludesInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Does not match the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLike: InputMaybe<Scalars['MediumText']>;
  /** Does not match the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLikeInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Does not start with the specified string (case-sensitive). */
  notStartsWith: InputMaybe<Scalars['MediumText']>;
  /** Does not start with the specified string (case-insensitive). */
  notStartsWithInsensitive: InputMaybe<Scalars['MediumText']>;
  /** Starts with the specified string (case-sensitive). */
  startsWith: InputMaybe<Scalars['MediumText']>;
  /** Starts with the specified string (case-insensitive). */
  startsWithInsensitive: InputMaybe<Scalars['MediumText']>;
};

/** The root mutation type which contains root level fields which mutate data. */
export type Mutation = {
  __typename?: 'Mutation';
  /** Creates a single `Brand`. */
  createBrand: Maybe<CreateBrandPayload>;
  /** Creates a single `Category`. */
  createCategory: Maybe<CreateCategoryPayload>;
  /** Creates a single `CheckIn`. */
  createCheckIn: Maybe<CreateCheckInPayload>;
  /** Creates a single `Company`. */
  createCompany: Maybe<CreateCompanyPayload>;
  /** Creates a single `Product`. */
  createProduct: Maybe<CreateProductPayload>;
  /** Creates a single `Type`. */
  createType: Maybe<CreateTypePayload>;
  /** Creates a single `User`. */
  createUser: Maybe<CreateUserPayload>;
  /** Deletes a single `Brand` using a unique key. */
  deleteBrand: Maybe<DeleteBrandPayload>;
  /** Deletes a single `Brand` using a unique key. */
  deleteBrandByCompanyIdAndName: Maybe<DeleteBrandPayload>;
  /** Deletes a single `Brand` using a unique key. */
  deleteBrandByNameAndCompanyId: Maybe<DeleteBrandPayload>;
  /** Deletes a single `Brand` using its globally unique id. */
  deleteBrandByNodeId: Maybe<DeleteBrandPayload>;
  /** Deletes a single `Category` using a unique key. */
  deleteCategory: Maybe<DeleteCategoryPayload>;
  /** Deletes a single `Category` using its globally unique id. */
  deleteCategoryByNodeId: Maybe<DeleteCategoryPayload>;
  /** Deletes a single `CheckIn` using a unique key. */
  deleteCheckIn: Maybe<DeleteCheckInPayload>;
  /** Deletes a single `CheckIn` using its globally unique id. */
  deleteCheckInByNodeId: Maybe<DeleteCheckInPayload>;
  /** Deletes a single `Company` using a unique key. */
  deleteCompany: Maybe<DeleteCompanyPayload>;
  /** Deletes a single `Company` using a unique key. */
  deleteCompanyByName: Maybe<DeleteCompanyPayload>;
  /** Deletes a single `Company` using its globally unique id. */
  deleteCompanyByNodeId: Maybe<DeleteCompanyPayload>;
  /** Deletes a single `Product` using a unique key. */
  deleteProduct: Maybe<DeleteProductPayload>;
  /** Deletes a single `Product` using a unique key. */
  deleteProductByNameAndBrandIdAndTypeId: Maybe<DeleteProductPayload>;
  /** Deletes a single `Product` using its globally unique id. */
  deleteProductByNodeId: Maybe<DeleteProductPayload>;
  /** Deletes a single `Type` using a unique key. */
  deleteType: Maybe<DeleteTypePayload>;
  /** Deletes a single `Type` using a unique key. */
  deleteTypeByNameAndCategory: Maybe<DeleteTypePayload>;
  /** Deletes a single `Type` using its globally unique id. */
  deleteTypeByNodeId: Maybe<DeleteTypePayload>;
  /** Deletes a single `User` using a unique key. */
  deleteUser: Maybe<DeleteUserPayload>;
  /** Deletes a single `User` using its globally unique id. */
  deleteUserByNodeId: Maybe<DeleteUserPayload>;
  /** Deletes a single `User` using a unique key. */
  deleteUserByUsername: Maybe<DeleteUserPayload>;
  login: Maybe<LoginPayload>;
  register: Maybe<RegisterPayload>;
  /** Updates a single `Brand` using a unique key and a patch. */
  updateBrand: Maybe<UpdateBrandPayload>;
  /** Updates a single `Brand` using a unique key and a patch. */
  updateBrandByCompanyIdAndName: Maybe<UpdateBrandPayload>;
  /** Updates a single `Brand` using a unique key and a patch. */
  updateBrandByNameAndCompanyId: Maybe<UpdateBrandPayload>;
  /** Updates a single `Brand` using its globally unique id and a patch. */
  updateBrandByNodeId: Maybe<UpdateBrandPayload>;
  /** Updates a single `Category` using a unique key and a patch. */
  updateCategory: Maybe<UpdateCategoryPayload>;
  /** Updates a single `Category` using its globally unique id and a patch. */
  updateCategoryByNodeId: Maybe<UpdateCategoryPayload>;
  /** Updates a single `CheckIn` using a unique key and a patch. */
  updateCheckIn: Maybe<UpdateCheckInPayload>;
  /** Updates a single `CheckIn` using its globally unique id and a patch. */
  updateCheckInByNodeId: Maybe<UpdateCheckInPayload>;
  /** Updates a single `Company` using a unique key and a patch. */
  updateCompany: Maybe<UpdateCompanyPayload>;
  /** Updates a single `Company` using a unique key and a patch. */
  updateCompanyByName: Maybe<UpdateCompanyPayload>;
  /** Updates a single `Company` using its globally unique id and a patch. */
  updateCompanyByNodeId: Maybe<UpdateCompanyPayload>;
  /** Updates a single `Product` using a unique key and a patch. */
  updateProduct: Maybe<UpdateProductPayload>;
  /** Updates a single `Product` using a unique key and a patch. */
  updateProductByNameAndBrandIdAndTypeId: Maybe<UpdateProductPayload>;
  /** Updates a single `Product` using its globally unique id and a patch. */
  updateProductByNodeId: Maybe<UpdateProductPayload>;
  /** Updates a single `Type` using a unique key and a patch. */
  updateType: Maybe<UpdateTypePayload>;
  /** Updates a single `Type` using a unique key and a patch. */
  updateTypeByNameAndCategory: Maybe<UpdateTypePayload>;
  /** Updates a single `Type` using its globally unique id and a patch. */
  updateTypeByNodeId: Maybe<UpdateTypePayload>;
  /** Updates a single `User` using a unique key and a patch. */
  updateUser: Maybe<UpdateUserPayload>;
  /** Updates a single `User` using its globally unique id and a patch. */
  updateUserByNodeId: Maybe<UpdateUserPayload>;
  /** Updates a single `User` using a unique key and a patch. */
  updateUserByUsername: Maybe<UpdateUserPayload>;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateBrandArgs = {
  input: CreateBrandInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCategoryArgs = {
  input: CreateCategoryInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCheckInArgs = {
  input: CreateCheckInInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCompanyArgs = {
  input: CreateCompanyInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateProductArgs = {
  input: CreateProductInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateTypeArgs = {
  input: CreateTypeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateUserArgs = {
  input: CreateUserInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteBrandArgs = {
  input: DeleteBrandInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteBrandByCompanyIdAndNameArgs = {
  input: DeleteBrandByCompanyIdAndNameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteBrandByNameAndCompanyIdArgs = {
  input: DeleteBrandByNameAndCompanyIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteBrandByNodeIdArgs = {
  input: DeleteBrandByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCategoryArgs = {
  input: DeleteCategoryInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCategoryByNodeIdArgs = {
  input: DeleteCategoryByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInArgs = {
  input: DeleteCheckInInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInByNodeIdArgs = {
  input: DeleteCheckInByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCompanyArgs = {
  input: DeleteCompanyInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCompanyByNameArgs = {
  input: DeleteCompanyByNameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCompanyByNodeIdArgs = {
  input: DeleteCompanyByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteProductArgs = {
  input: DeleteProductInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteProductByNameAndBrandIdAndTypeIdArgs = {
  input: DeleteProductByNameAndBrandIdAndTypeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteProductByNodeIdArgs = {
  input: DeleteProductByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteTypeArgs = {
  input: DeleteTypeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteTypeByNameAndCategoryArgs = {
  input: DeleteTypeByNameAndCategoryInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteTypeByNodeIdArgs = {
  input: DeleteTypeByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserArgs = {
  input: DeleteUserInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserByNodeIdArgs = {
  input: DeleteUserByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserByUsernameArgs = {
  input: DeleteUserByUsernameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationLoginArgs = {
  input: LoginInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationRegisterArgs = {
  input: RegisterInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateBrandArgs = {
  input: UpdateBrandInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateBrandByCompanyIdAndNameArgs = {
  input: UpdateBrandByCompanyIdAndNameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateBrandByNameAndCompanyIdArgs = {
  input: UpdateBrandByNameAndCompanyIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateBrandByNodeIdArgs = {
  input: UpdateBrandByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCategoryArgs = {
  input: UpdateCategoryInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCategoryByNodeIdArgs = {
  input: UpdateCategoryByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInArgs = {
  input: UpdateCheckInInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInByNodeIdArgs = {
  input: UpdateCheckInByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCompanyArgs = {
  input: UpdateCompanyInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCompanyByNameArgs = {
  input: UpdateCompanyByNameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCompanyByNodeIdArgs = {
  input: UpdateCompanyByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateProductArgs = {
  input: UpdateProductInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateProductByNameAndBrandIdAndTypeIdArgs = {
  input: UpdateProductByNameAndBrandIdAndTypeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateProductByNodeIdArgs = {
  input: UpdateProductByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateTypeArgs = {
  input: UpdateTypeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateTypeByNameAndCategoryArgs = {
  input: UpdateTypeByNameAndCategoryInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateTypeByNodeIdArgs = {
  input: UpdateTypeByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserArgs = {
  input: UpdateUserInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserByNodeIdArgs = {
  input: UpdateUserByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserByUsernameArgs = {
  input: UpdateUserByUsernameInput;
};

/** An object with a globally unique `ID`. */
export type Node = {
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
};

/** Information about pagination in a connection. */
export type PageInfo = {
  __typename?: 'PageInfo';
  /** When paginating forwards, the cursor to continue. */
  endCursor: Maybe<Scalars['Cursor']>;
  /** When paginating forwards, are there more items? */
  hasNextPage: Scalars['Boolean'];
  /** When paginating backwards, are there more items? */
  hasPreviousPage: Scalars['Boolean'];
  /** When paginating backwards, the cursor to continue. */
  startCursor: Maybe<Scalars['Cursor']>;
};

export type Product = Node & {
  __typename?: 'Product';
  /** Reads a single `Brand` that is related to this `Product`. */
  brand: Maybe<Brand>;
  brandId: Scalars['Int'];
  /** Reads and enables pagination through a set of `CheckIn`. */
  checkIns: CheckInsConnection;
  checkInsPastMonth: Maybe<Scalars['Int']>;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  description: Maybe<Scalars['LongText']>;
  id: Scalars['Int'];
  isVerified: Maybe<Scalars['Boolean']>;
  /** Reads a single `Company` that is related to this `Product`. */
  manufacturer: Maybe<Company>;
  manufacturerId: Maybe<Scalars['Int']>;
  name: Maybe<Scalars['MediumText']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  totalCheckIns: Maybe<Scalars['Int']>;
  /** Reads a single `Type` that is related to this `Product`. */
  type: Maybe<Type>;
  typeId: Scalars['Int'];
  updatedAt: Scalars['Datetime'];
  updatedBy: Maybe<Scalars['UUID']>;
  /** Reads a single `User` that is related to this `Product`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Product`. */
  userByUpdatedBy: Maybe<User>;
};


export type ProductCheckInsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCondition>;
  filter: InputMaybe<CheckInFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** A condition to be used against `Product` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type ProductCondition = {
  /** Checks for equality with the object’s `brandId` field. */
  brandId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `createdBy` field. */
  createdBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `description` field. */
  description: InputMaybe<Scalars['LongText']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `manufacturerId` field. */
  manufacturerId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['MediumText']>;
  /** Checks for equality with the object’s `typeId` field. */
  typeId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `updatedBy` field. */
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** A filter to be used against `Product` object types. All fields are combined with a logical ‘and.’ */
export type ProductFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<ProductFilter>>;
  /** Filter by the object’s `brandId` field. */
  brandId: InputMaybe<IntFilter>;
  /** Filter by the object’s `checkInsPastMonth` field. */
  checkInsPastMonth: InputMaybe<IntFilter>;
  /** Filter by the object’s `createdAt` field. */
  createdAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `createdBy` field. */
  createdBy: InputMaybe<UuidFilter>;
  /** Filter by the object’s `description` field. */
  description: InputMaybe<LongTextFilter>;
  /** Filter by the object’s `id` field. */
  id: InputMaybe<IntFilter>;
  /** Filter by the object’s `isVerified` field. */
  isVerified: InputMaybe<BooleanFilter>;
  /** Filter by the object’s `manufacturerId` field. */
  manufacturerId: InputMaybe<IntFilter>;
  /** Filter by the object’s `name` field. */
  name: InputMaybe<MediumTextFilter>;
  /** Negates the expression. */
  not: InputMaybe<ProductFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<ProductFilter>>;
  /** Filter by the object’s `totalCheckIns` field. */
  totalCheckIns: InputMaybe<IntFilter>;
  /** Filter by the object’s `typeId` field. */
  typeId: InputMaybe<IntFilter>;
  /** Filter by the object’s `updatedAt` field. */
  updatedAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `updatedBy` field. */
  updatedBy: InputMaybe<UuidFilter>;
};

/** An input for mutations affecting `Product` */
export type ProductInput = {
  brandId: Scalars['Int'];
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  description: InputMaybe<Scalars['LongText']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  manufacturerId: InputMaybe<Scalars['Int']>;
  name: InputMaybe<Scalars['MediumText']>;
  typeId: Scalars['Int'];
  updatedAt: InputMaybe<Scalars['Datetime']>;
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** Represents an update to a `Product`. Fields that are set will be updated. */
export type ProductPatch = {
  brandId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  description: InputMaybe<Scalars['LongText']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  manufacturerId: InputMaybe<Scalars['Int']>;
  name: InputMaybe<Scalars['MediumText']>;
  typeId: InputMaybe<Scalars['Int']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `Product` values. */
export type ProductsConnection = {
  __typename?: 'ProductsConnection';
  /** A list of edges which contains the `Product` and cursor to aid in pagination. */
  edges: Array<ProductsEdge>;
  /** A list of `Product` objects. */
  nodes: Array<Maybe<Product>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Product` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Product` edge in the connection. */
export type ProductsEdge = {
  __typename?: 'ProductsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Product` at the end of the edge. */
  node: Maybe<Product>;
};

/** Methods to use when ordering `Product`. */
export enum ProductsOrderBy {
  BrandIdAsc = 'BRAND_ID_ASC',
  BrandIdDesc = 'BRAND_ID_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  CreatedByAsc = 'CREATED_BY_ASC',
  CreatedByDesc = 'CREATED_BY_DESC',
  DescriptionAsc = 'DESCRIPTION_ASC',
  DescriptionDesc = 'DESCRIPTION_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsVerifiedAsc = 'IS_VERIFIED_ASC',
  IsVerifiedDesc = 'IS_VERIFIED_DESC',
  ManufacturerIdAsc = 'MANUFACTURER_ID_ASC',
  ManufacturerIdDesc = 'MANUFACTURER_ID_DESC',
  NameAsc = 'NAME_ASC',
  NameDesc = 'NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  TypeIdAsc = 'TYPE_ID_ASC',
  TypeIdDesc = 'TYPE_ID_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UpdatedByAsc = 'UPDATED_BY_ASC',
  UpdatedByDesc = 'UPDATED_BY_DESC'
}

/** The root query type which gives access points into the data universe. */
export type Query = Node & {
  __typename?: 'Query';
  brand: Maybe<Brand>;
  brandByCompanyIdAndName: Maybe<Brand>;
  brandByNameAndCompanyId: Maybe<Brand>;
  /** Reads a single `Brand` using its globally unique `ID`. */
  brandByNodeId: Maybe<Brand>;
  /** Reads and enables pagination through a set of `Brand`. */
  brands: Maybe<BrandsConnection>;
  /** Reads and enables pagination through a set of `Category`. */
  categories: Maybe<CategoriesConnection>;
  category: Maybe<Category>;
  /** Reads a single `Category` using its globally unique `ID`. */
  categoryByNodeId: Maybe<Category>;
  checkIn: Maybe<CheckIn>;
  /** Reads a single `CheckIn` using its globally unique `ID`. */
  checkInByNodeId: Maybe<CheckIn>;
  /** Reads and enables pagination through a set of `CheckIn`. */
  checkIns: Maybe<CheckInsConnection>;
  /** Reads and enables pagination through a set of `Company`. */
  companies: Maybe<CompaniesConnection>;
  company: Maybe<Company>;
  companyByName: Maybe<Company>;
  /** Reads a single `Company` using its globally unique `ID`. */
  companyByNodeId: Maybe<Company>;
  /** Fetches an object given its globally unique `ID`. */
  node: Maybe<Node>;
  /** The root query type must be a `Node` to work well with Relay 1 mutations. This just resolves to `query`. */
  nodeId: Scalars['ID'];
  product: Maybe<Product>;
  productByNameAndBrandIdAndTypeId: Maybe<Product>;
  /** Reads a single `Product` using its globally unique `ID`. */
  productByNodeId: Maybe<Product>;
  /** Reads and enables pagination through a set of `Product`. */
  products: Maybe<ProductsConnection>;
  /**
   * Exposes the root query type nested one level down. This is helpful for Relay 1
   * which can only query top level fields if they are in a particular form.
   */
  query: Query;
  /** Reads and enables pagination through a set of `Product`. */
  searchProducts: Maybe<ProductsConnection>;
  type: Maybe<Type>;
  typeByNameAndCategory: Maybe<Type>;
  /** Reads a single `Type` using its globally unique `ID`. */
  typeByNodeId: Maybe<Type>;
  /** Reads and enables pagination through a set of `Type`. */
  types: Maybe<TypesConnection>;
  user: Maybe<User>;
  /** Reads a single `User` using its globally unique `ID`. */
  userByNodeId: Maybe<User>;
  userByUsername: Maybe<User>;
  /** Reads and enables pagination through a set of `User`. */
  users: Maybe<UsersConnection>;
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandByCompanyIdAndNameArgs = {
  companyId: Scalars['Int'];
  name: Scalars['MediumText'];
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandByNameAndCompanyIdArgs = {
  companyId: Scalars['Int'];
  name: Scalars['MediumText'];
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  filter: InputMaybe<BrandFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCategoriesArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CategoryCondition>;
  filter: InputMaybe<CategoryFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CategoriesOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCategoryArgs = {
  name: Scalars['String'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCategoryByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCondition>;
  filter: InputMaybe<CheckInFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCompaniesArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CompanyCondition>;
  filter: InputMaybe<CompanyFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyByNameArgs = {
  name: Scalars['MediumText'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryNodeArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryProductArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryProductByNameAndBrandIdAndTypeIdArgs = {
  brandId: Scalars['Int'];
  name: Scalars['MediumText'];
  typeId: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryProductByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryProductsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QuerySearchProductsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  search: InputMaybe<Scalars['String']>;
};


/** The root query type which gives access points into the data universe. */
export type QueryTypeArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryTypeByNameAndCategoryArgs = {
  category: Scalars['String'];
  name: Scalars['String'];
};


/** The root query type which gives access points into the data universe. */
export type QueryTypeByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryTypesArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<TypeCondition>;
  filter: InputMaybe<TypeFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<TypesOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryUserArgs = {
  id: Scalars['UUID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserByUsernameArgs = {
  username: Scalars['String'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUsersArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<UserCondition>;
  filter: InputMaybe<UserFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<UsersOrderBy>>;
};

/** All input for the `register` mutation. */
export type RegisterInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  password: InputMaybe<Scalars['String']>;
  username: Scalars['String'];
};

/** The output of our `register` mutation. */
export type RegisterPayload = {
  __typename?: 'RegisterPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  user: Maybe<User>;
  /** An edge for our `User`. May be used by Relay 1. */
  userEdge: Maybe<UsersEdge>;
};


/** The output of our `register` mutation. */
export type RegisterPayloadUserEdgeArgs = {
  orderBy?: InputMaybe<Array<UsersOrderBy>>;
};

/** A filter to be used against ShortText fields. All fields are combined with a logical ‘and.’ */
export type ShortTextFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['ShortText']>;
  /** Not equal to the specified value, treating null like an ordinary value (case-insensitive). */
  distinctFromInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Ends with the specified string (case-sensitive). */
  endsWith: InputMaybe<Scalars['ShortText']>;
  /** Ends with the specified string (case-insensitive). */
  endsWithInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['ShortText']>;
  /** Equal to the specified value (case-insensitive). */
  equalToInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['ShortText']>;
  /** Greater than the specified value (case-insensitive). */
  greaterThanInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['ShortText']>;
  /** Greater than or equal to the specified value (case-insensitive). */
  greaterThanOrEqualToInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['ShortText']>>;
  /** Included in the specified list (case-insensitive). */
  inInsensitive: InputMaybe<Array<Scalars['ShortText']>>;
  /** Contains the specified string (case-sensitive). */
  includes: InputMaybe<Scalars['ShortText']>;
  /** Contains the specified string (case-insensitive). */
  includesInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['ShortText']>;
  /** Less than the specified value (case-insensitive). */
  lessThanInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['ShortText']>;
  /** Less than or equal to the specified value (case-insensitive). */
  lessThanOrEqualToInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Matches the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  like: InputMaybe<Scalars['ShortText']>;
  /** Matches the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  likeInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['ShortText']>;
  /** Equal to the specified value, treating null like an ordinary value (case-insensitive). */
  notDistinctFromInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Does not end with the specified string (case-sensitive). */
  notEndsWith: InputMaybe<Scalars['ShortText']>;
  /** Does not end with the specified string (case-insensitive). */
  notEndsWithInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['ShortText']>;
  /** Not equal to the specified value (case-insensitive). */
  notEqualToInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['ShortText']>>;
  /** Not included in the specified list (case-insensitive). */
  notInInsensitive: InputMaybe<Array<Scalars['ShortText']>>;
  /** Does not contain the specified string (case-sensitive). */
  notIncludes: InputMaybe<Scalars['ShortText']>;
  /** Does not contain the specified string (case-insensitive). */
  notIncludesInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Does not match the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLike: InputMaybe<Scalars['ShortText']>;
  /** Does not match the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLikeInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Does not start with the specified string (case-sensitive). */
  notStartsWith: InputMaybe<Scalars['ShortText']>;
  /** Does not start with the specified string (case-insensitive). */
  notStartsWithInsensitive: InputMaybe<Scalars['ShortText']>;
  /** Starts with the specified string (case-sensitive). */
  startsWith: InputMaybe<Scalars['ShortText']>;
  /** Starts with the specified string (case-insensitive). */
  startsWithInsensitive: InputMaybe<Scalars['ShortText']>;
};

/** A filter to be used against String fields. All fields are combined with a logical ‘and.’ */
export type StringFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['String']>;
  /** Not equal to the specified value, treating null like an ordinary value (case-insensitive). */
  distinctFromInsensitive: InputMaybe<Scalars['String']>;
  /** Ends with the specified string (case-sensitive). */
  endsWith: InputMaybe<Scalars['String']>;
  /** Ends with the specified string (case-insensitive). */
  endsWithInsensitive: InputMaybe<Scalars['String']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['String']>;
  /** Equal to the specified value (case-insensitive). */
  equalToInsensitive: InputMaybe<Scalars['String']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['String']>;
  /** Greater than the specified value (case-insensitive). */
  greaterThanInsensitive: InputMaybe<Scalars['String']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['String']>;
  /** Greater than or equal to the specified value (case-insensitive). */
  greaterThanOrEqualToInsensitive: InputMaybe<Scalars['String']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['String']>>;
  /** Included in the specified list (case-insensitive). */
  inInsensitive: InputMaybe<Array<Scalars['String']>>;
  /** Contains the specified string (case-sensitive). */
  includes: InputMaybe<Scalars['String']>;
  /** Contains the specified string (case-insensitive). */
  includesInsensitive: InputMaybe<Scalars['String']>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['String']>;
  /** Less than the specified value (case-insensitive). */
  lessThanInsensitive: InputMaybe<Scalars['String']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['String']>;
  /** Less than or equal to the specified value (case-insensitive). */
  lessThanOrEqualToInsensitive: InputMaybe<Scalars['String']>;
  /** Matches the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  like: InputMaybe<Scalars['String']>;
  /** Matches the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  likeInsensitive: InputMaybe<Scalars['String']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['String']>;
  /** Equal to the specified value, treating null like an ordinary value (case-insensitive). */
  notDistinctFromInsensitive: InputMaybe<Scalars['String']>;
  /** Does not end with the specified string (case-sensitive). */
  notEndsWith: InputMaybe<Scalars['String']>;
  /** Does not end with the specified string (case-insensitive). */
  notEndsWithInsensitive: InputMaybe<Scalars['String']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['String']>;
  /** Not equal to the specified value (case-insensitive). */
  notEqualToInsensitive: InputMaybe<Scalars['String']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['String']>>;
  /** Not included in the specified list (case-insensitive). */
  notInInsensitive: InputMaybe<Array<Scalars['String']>>;
  /** Does not contain the specified string (case-sensitive). */
  notIncludes: InputMaybe<Scalars['String']>;
  /** Does not contain the specified string (case-insensitive). */
  notIncludesInsensitive: InputMaybe<Scalars['String']>;
  /** Does not match the specified pattern (case-sensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLike: InputMaybe<Scalars['String']>;
  /** Does not match the specified pattern (case-insensitive). An underscore (_) matches any single character; a percent sign (%) matches any sequence of zero or more characters. */
  notLikeInsensitive: InputMaybe<Scalars['String']>;
  /** Does not start with the specified string (case-sensitive). */
  notStartsWith: InputMaybe<Scalars['String']>;
  /** Does not start with the specified string (case-insensitive). */
  notStartsWithInsensitive: InputMaybe<Scalars['String']>;
  /** Starts with the specified string (case-sensitive). */
  startsWith: InputMaybe<Scalars['String']>;
  /** Starts with the specified string (case-insensitive). */
  startsWithInsensitive: InputMaybe<Scalars['String']>;
};

export type Type = Node & {
  __typename?: 'Type';
  category: Scalars['String'];
  /** Reads a single `Category` that is related to this `Type`. */
  categoryByCategory: Maybe<Category>;
  id: Scalars['Int'];
  name: Scalars['String'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Product`. */
  products: ProductsConnection;
};


export type TypeProductsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** A condition to be used against `Type` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type TypeCondition = {
  /** Checks for equality with the object’s `category` field. */
  category: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['String']>;
};

/** A filter to be used against `Type` object types. All fields are combined with a logical ‘and.’ */
export type TypeFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<TypeFilter>>;
  /** Filter by the object’s `category` field. */
  category: InputMaybe<StringFilter>;
  /** Filter by the object’s `id` field. */
  id: InputMaybe<IntFilter>;
  /** Filter by the object’s `name` field. */
  name: InputMaybe<StringFilter>;
  /** Negates the expression. */
  not: InputMaybe<TypeFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<TypeFilter>>;
};

/** An input for mutations affecting `Type` */
export type TypeInput = {
  category: Scalars['String'];
  id: InputMaybe<Scalars['Int']>;
  name: Scalars['String'];
};

/** Represents an update to a `Type`. Fields that are set will be updated. */
export type TypePatch = {
  category: InputMaybe<Scalars['String']>;
  id: InputMaybe<Scalars['Int']>;
  name: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `Type` values. */
export type TypesConnection = {
  __typename?: 'TypesConnection';
  /** A list of edges which contains the `Type` and cursor to aid in pagination. */
  edges: Array<TypesEdge>;
  /** A list of `Type` objects. */
  nodes: Array<Maybe<Type>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Type` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Type` edge in the connection. */
export type TypesEdge = {
  __typename?: 'TypesEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Type` at the end of the edge. */
  node: Maybe<Type>;
};

/** Methods to use when ordering `Type`. */
export enum TypesOrderBy {
  CategoryAsc = 'CATEGORY_ASC',
  CategoryDesc = 'CATEGORY_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  NameAsc = 'NAME_ASC',
  NameDesc = 'NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

/** A filter to be used against UUID fields. All fields are combined with a logical ‘and.’ */
export type UuidFilter = {
  /** Not equal to the specified value, treating null like an ordinary value. */
  distinctFrom: InputMaybe<Scalars['UUID']>;
  /** Equal to the specified value. */
  equalTo: InputMaybe<Scalars['UUID']>;
  /** Greater than the specified value. */
  greaterThan: InputMaybe<Scalars['UUID']>;
  /** Greater than or equal to the specified value. */
  greaterThanOrEqualTo: InputMaybe<Scalars['UUID']>;
  /** Included in the specified list. */
  in: InputMaybe<Array<Scalars['UUID']>>;
  /** Is null (if `true` is specified) or is not null (if `false` is specified). */
  isNull: InputMaybe<Scalars['Boolean']>;
  /** Less than the specified value. */
  lessThan: InputMaybe<Scalars['UUID']>;
  /** Less than or equal to the specified value. */
  lessThanOrEqualTo: InputMaybe<Scalars['UUID']>;
  /** Equal to the specified value, treating null like an ordinary value. */
  notDistinctFrom: InputMaybe<Scalars['UUID']>;
  /** Not equal to the specified value. */
  notEqualTo: InputMaybe<Scalars['UUID']>;
  /** Not included in the specified list. */
  notIn: InputMaybe<Array<Scalars['UUID']>>;
};

/** All input for the `updateBrandByCompanyIdAndName` mutation. */
export type UpdateBrandByCompanyIdAndNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  companyId: Scalars['Int'];
  name: Scalars['MediumText'];
  /** An object where the defined keys will be set on the `Brand` being updated. */
  patch: BrandPatch;
};

/** All input for the `updateBrandByNameAndCompanyId` mutation. */
export type UpdateBrandByNameAndCompanyIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  companyId: Scalars['Int'];
  name: Scalars['MediumText'];
  /** An object where the defined keys will be set on the `Brand` being updated. */
  patch: BrandPatch;
};

/** All input for the `updateBrandByNodeId` mutation. */
export type UpdateBrandByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Brand` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Brand` being updated. */
  patch: BrandPatch;
};

/** All input for the `updateBrand` mutation. */
export type UpdateBrandInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `Brand` being updated. */
  patch: BrandPatch;
};

/** The output of our update `Brand` mutation. */
export type UpdateBrandPayload = {
  __typename?: 'UpdateBrandPayload';
  /** The `Brand` that was updated by this mutation. */
  brand: Maybe<Brand>;
  /** An edge for our `Brand`. May be used by Relay 1. */
  brandEdge: Maybe<BrandsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `Brand`. */
  company: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Brand`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our update `Brand` mutation. */
export type UpdateBrandPayloadBrandEdgeArgs = {
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};

/** All input for the `updateCategoryByNodeId` mutation. */
export type UpdateCategoryByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Category` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Category` being updated. */
  patch: CategoryPatch;
};

/** All input for the `updateCategory` mutation. */
export type UpdateCategoryInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
  /** An object where the defined keys will be set on the `Category` being updated. */
  patch: CategoryPatch;
};

/** The output of our update `Category` mutation. */
export type UpdateCategoryPayload = {
  __typename?: 'UpdateCategoryPayload';
  /** The `Category` that was updated by this mutation. */
  category: Maybe<Category>;
  /** An edge for our `Category`. May be used by Relay 1. */
  categoryEdge: Maybe<CategoriesEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our update `Category` mutation. */
export type UpdateCategoryPayloadCategoryEdgeArgs = {
  orderBy?: InputMaybe<Array<CategoriesOrderBy>>;
};

/** All input for the `updateCheckInByNodeId` mutation. */
export type UpdateCheckInByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckIn` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `CheckIn` being updated. */
  patch: CheckInPatch;
};

/** All input for the `updateCheckIn` mutation. */
export type UpdateCheckInInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `CheckIn` being updated. */
  patch: CheckInPatch;
};

/** The output of our update `CheckIn` mutation. */
export type UpdateCheckInPayload = {
  __typename?: 'UpdateCheckInPayload';
  /** Reads a single `User` that is related to this `CheckIn`. */
  author: Maybe<User>;
  /** The `CheckIn` that was updated by this mutation. */
  checkIn: Maybe<CheckIn>;
  /** An edge for our `CheckIn`. May be used by Relay 1. */
  checkInEdge: Maybe<CheckInsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Product` that is related to this `CheckIn`. */
  product: Maybe<Product>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our update `CheckIn` mutation. */
export type UpdateCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the `updateCompanyByName` mutation. */
export type UpdateCompanyByNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['MediumText'];
  /** An object where the defined keys will be set on the `Company` being updated. */
  patch: CompanyPatch;
};

/** All input for the `updateCompanyByNodeId` mutation. */
export type UpdateCompanyByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Company` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Company` being updated. */
  patch: CompanyPatch;
};

/** All input for the `updateCompany` mutation. */
export type UpdateCompanyInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `Company` being updated. */
  patch: CompanyPatch;
};

/** The output of our update `Company` mutation. */
export type UpdateCompanyPayload = {
  __typename?: 'UpdateCompanyPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Company` that was updated by this mutation. */
  company: Maybe<Company>;
  /** An edge for our `Company`. May be used by Relay 1. */
  companyEdge: Maybe<CompaniesEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Company`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our update `Company` mutation. */
export type UpdateCompanyPayloadCompanyEdgeArgs = {
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};

/** All input for the `updateProductByNameAndBrandIdAndTypeId` mutation. */
export type UpdateProductByNameAndBrandIdAndTypeIdInput = {
  brandId: Scalars['Int'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['MediumText'];
  /** An object where the defined keys will be set on the `Product` being updated. */
  patch: ProductPatch;
  typeId: Scalars['Int'];
};

/** All input for the `updateProductByNodeId` mutation. */
export type UpdateProductByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Product` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Product` being updated. */
  patch: ProductPatch;
};

/** All input for the `updateProduct` mutation. */
export type UpdateProductInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `Product` being updated. */
  patch: ProductPatch;
};

/** The output of our update `Product` mutation. */
export type UpdateProductPayload = {
  __typename?: 'UpdateProductPayload';
  /** Reads a single `Brand` that is related to this `Product`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `Product`. */
  manufacturer: Maybe<Company>;
  /** The `Product` that was updated by this mutation. */
  product: Maybe<Product>;
  /** An edge for our `Product`. May be used by Relay 1. */
  productEdge: Maybe<ProductsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `Product`. */
  type: Maybe<Type>;
  /** Reads a single `User` that is related to this `Product`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Product`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our update `Product` mutation. */
export type UpdateProductPayloadProductEdgeArgs = {
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** All input for the `updateTypeByNameAndCategory` mutation. */
export type UpdateTypeByNameAndCategoryInput = {
  category: Scalars['String'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
  /** An object where the defined keys will be set on the `Type` being updated. */
  patch: TypePatch;
};

/** All input for the `updateTypeByNodeId` mutation. */
export type UpdateTypeByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Type` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Type` being updated. */
  patch: TypePatch;
};

/** All input for the `updateType` mutation. */
export type UpdateTypeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `Type` being updated. */
  patch: TypePatch;
};

/** The output of our update `Type` mutation. */
export type UpdateTypePayload = {
  __typename?: 'UpdateTypePayload';
  /** Reads a single `Category` that is related to this `Type`. */
  categoryByCategory: Maybe<Category>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `Type` that was updated by this mutation. */
  type: Maybe<Type>;
  /** An edge for our `Type`. May be used by Relay 1. */
  typeEdge: Maybe<TypesEdge>;
};


/** The output of our update `Type` mutation. */
export type UpdateTypePayloadTypeEdgeArgs = {
  orderBy?: InputMaybe<Array<TypesOrderBy>>;
};

/** All input for the `updateUserByNodeId` mutation. */
export type UpdateUserByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `User` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `User` being updated. */
  patch: UserPatch;
};

/** All input for the `updateUserByUsername` mutation. */
export type UpdateUserByUsernameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** An object where the defined keys will be set on the `User` being updated. */
  patch: UserPatch;
  username: Scalars['String'];
};

/** All input for the `updateUser` mutation. */
export type UpdateUserInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
  /** An object where the defined keys will be set on the `User` being updated. */
  patch: UserPatch;
};

/** The output of our update `User` mutation. */
export type UpdateUserPayload = {
  __typename?: 'UpdateUserPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `User` that was updated by this mutation. */
  user: Maybe<User>;
  /** An edge for our `User`. May be used by Relay 1. */
  userEdge: Maybe<UsersEdge>;
};


/** The output of our update `User` mutation. */
export type UpdateUserPayloadUserEdgeArgs = {
  orderBy?: InputMaybe<Array<UsersOrderBy>>;
};

export type User = Node & {
  __typename?: 'User';
  /** Reads and enables pagination through a set of `CheckIn`. */
  authoredCheckIns: CheckInsConnection;
  /** Reads and enables pagination through a set of `Brand`. */
  brandsByCreatedBy: BrandsConnection;
  /** Reads and enables pagination through a set of `Brand`. */
  brandsByUpdatedBy: BrandsConnection;
  /** Reads and enables pagination through a set of `Company`. */
  companiesByCreatedBy: CompaniesConnection;
  createdAt: Scalars['Datetime'];
  firstName: Maybe<Scalars['ShortText']>;
  id: Scalars['UUID'];
  isAdmin: Scalars['Boolean'];
  isVerified: Scalars['Boolean'];
  lastName: Maybe<Scalars['ShortText']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Product`. */
  productsByCreatedBy: ProductsConnection;
  /** Reads and enables pagination through a set of `Product`. */
  productsByUpdatedBy: ProductsConnection;
  updatedAt: Scalars['Datetime'];
  username: Scalars['String'];
};


export type UserAuthoredCheckInsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCondition>;
  filter: InputMaybe<CheckInFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};


export type UserBrandsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  filter: InputMaybe<BrandFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


export type UserBrandsByUpdatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  filter: InputMaybe<BrandFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


export type UserCompaniesByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CompanyCondition>;
  filter: InputMaybe<CompanyFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};


export type UserProductsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};


export type UserProductsByUpdatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  filter: InputMaybe<ProductFilter>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};

/** A condition to be used against `User` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type UserCondition = {
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `firstName` field. */
  firstName: InputMaybe<Scalars['ShortText']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `isAdmin` field. */
  isAdmin: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `lastName` field. */
  lastName: InputMaybe<Scalars['ShortText']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `username` field. */
  username: InputMaybe<Scalars['String']>;
};

/** A filter to be used against `User` object types. All fields are combined with a logical ‘and.’ */
export type UserFilter = {
  /** Checks for all expressions in this list. */
  and: InputMaybe<Array<UserFilter>>;
  /** Filter by the object’s `createdAt` field. */
  createdAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `firstName` field. */
  firstName: InputMaybe<ShortTextFilter>;
  /** Filter by the object’s `id` field. */
  id: InputMaybe<UuidFilter>;
  /** Filter by the object’s `isAdmin` field. */
  isAdmin: InputMaybe<BooleanFilter>;
  /** Filter by the object’s `isVerified` field. */
  isVerified: InputMaybe<BooleanFilter>;
  /** Filter by the object’s `lastName` field. */
  lastName: InputMaybe<ShortTextFilter>;
  /** Negates the expression. */
  not: InputMaybe<UserFilter>;
  /** Checks for any expressions in this list. */
  or: InputMaybe<Array<UserFilter>>;
  /** Filter by the object’s `updatedAt` field. */
  updatedAt: InputMaybe<DatetimeFilter>;
  /** Filter by the object’s `username` field. */
  username: InputMaybe<StringFilter>;
};

/** An input for mutations affecting `User` */
export type UserInput = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  firstName: InputMaybe<Scalars['ShortText']>;
  id: InputMaybe<Scalars['UUID']>;
  isAdmin: InputMaybe<Scalars['Boolean']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  lastName: InputMaybe<Scalars['ShortText']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  username: Scalars['String'];
};

/** Represents an update to a `User`. Fields that are set will be updated. */
export type UserPatch = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  firstName: InputMaybe<Scalars['ShortText']>;
  id: InputMaybe<Scalars['UUID']>;
  isAdmin: InputMaybe<Scalars['Boolean']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  lastName: InputMaybe<Scalars['ShortText']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  username: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `User` values. */
export type UsersConnection = {
  __typename?: 'UsersConnection';
  /** A list of edges which contains the `User` and cursor to aid in pagination. */
  edges: Array<UsersEdge>;
  /** A list of `User` objects. */
  nodes: Array<Maybe<User>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `User` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `User` edge in the connection. */
export type UsersEdge = {
  __typename?: 'UsersEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `User` at the end of the edge. */
  node: Maybe<User>;
};

/** Methods to use when ordering `User`. */
export enum UsersOrderBy {
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  FirstNameAsc = 'FIRST_NAME_ASC',
  FirstNameDesc = 'FIRST_NAME_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsAdminAsc = 'IS_ADMIN_ASC',
  IsAdminDesc = 'IS_ADMIN_DESC',
  IsVerifiedAsc = 'IS_VERIFIED_ASC',
  IsVerifiedDesc = 'IS_VERIFIED_DESC',
  LastNameAsc = 'LAST_NAME_ASC',
  LastNameDesc = 'LAST_NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UsernameAsc = 'USERNAME_ASC',
  UsernameDesc = 'USERNAME_DESC'
}

export type Basic_ProductFragment = { __typename?: 'Product', id: number, name: any, brand: { __typename?: 'Brand', id: number, name: any, company: { __typename?: 'Company', id: number, name: any } }, manufacturer: { __typename?: 'Company', id: number, name: any }, type: { __typename?: 'Type', id: number, category: string, name: string } };

export type Basic_UserFragment = { __typename?: 'User', id: any, username: string };

export type GetActivityFeedQueryVariables = Exact<{ [key: string]: never; }>;


export type GetActivityFeedQuery = { __typename?: 'Query', checkIns: { __typename?: 'CheckInsConnection', nodes: Array<{ __typename?: 'CheckIn', id: number, rating: number, review: string, checkInDate: any, createdAt: any, author: { __typename?: 'User', id: any, username: string }, product: { __typename?: 'Product', id: number, name: any, brand: { __typename?: 'Brand', id: number, name: any, company: { __typename?: 'Company', id: number, name: any } }, manufacturer: { __typename?: 'Company', id: number, name: any }, type: { __typename?: 'Type', id: number, category: string, name: string } } }> } };

export type GetCompaniesQueryVariables = Exact<{ [key: string]: never; }>;


export type GetCompaniesQuery = { __typename?: 'Query', companies: { __typename?: 'CompaniesConnection', nodes: Array<{ __typename?: 'Company', id: number, name: any, brands: { __typename?: 'BrandsConnection', nodes: Array<{ __typename?: 'Brand', id: number, name: any }> } }> } };

export type GetCompanyByIdQueryVariables = Exact<{
  companyId: Scalars['Int'];
}>;


export type GetCompanyByIdQuery = { __typename?: 'Query', company: { __typename?: 'Company', id: number, name: any, brands: { __typename?: 'BrandsConnection', edges: Array<{ __typename?: 'BrandsEdge', node: { __typename?: 'Brand', id: number, name: any, products: { __typename?: 'ProductsConnection', edges: Array<{ __typename?: 'ProductsEdge', node: { __typename?: 'Product', id: number, name: any, manufacturer: { __typename?: 'Company', id: number, name: any }, type: { __typename?: 'Type', id: number, name: string, category: string } } }> } } }> } } };

export type GetProductByIdQueryVariables = Exact<{
  productId: Scalars['Int'];
}>;


export type GetProductByIdQuery = { __typename?: 'Query', product: { __typename?: 'Product', name: any, id: number, brand: { __typename?: 'Brand', id: number, name: any, company: { __typename?: 'Company', name: any, id: number } }, checkIns: { __typename?: 'CheckInsConnection', nodes: Array<{ __typename?: 'CheckIn', id: number, rating: number, review: string, author: { __typename?: 'User', id: any, username: string } }> }, manufacturer: { __typename?: 'Company', id: number, name: any }, type: { __typename?: 'Type', name: string, id: number, category: string } } };

export type GetUserByIdQueryVariables = Exact<{
  userId: Scalars['UUID'];
}>;


export type GetUserByIdQuery = { __typename?: 'Query', user: { __typename?: 'User', firstName: any, lastName: any, id: any, username: string } };

export type LoginMutationVariables = Exact<{
  username: Scalars['String'];
  password: Scalars['String'];
}>;


export type LoginMutation = { __typename?: 'Mutation', login: { __typename?: 'LoginPayload', user: { __typename?: 'User', id: any, username: string } } };

export type RegisterMutationVariables = Exact<{
  username: Scalars['String'];
  password: Scalars['String'];
}>;


export type RegisterMutation = { __typename?: 'Mutation', register: { __typename?: 'RegisterPayload', user: { __typename?: 'User', id: any, username: string } } };

export type UpdateUserMutationVariables = Exact<{
  id: Scalars['UUID'];
  username: Scalars['String'];
  firstName: Scalars['ShortText'];
  lastName: Scalars['ShortText'];
}>;


export type UpdateUserMutation = { __typename?: 'Mutation', updateUser: { __typename?: 'UpdateUserPayload', user: { __typename?: 'User', username: string, id: any } } };

export const Basic_ProductFragmentDoc = gql`
    fragment Basic_Product on Product {
  id
  name
  brand {
    id
    name
    company {
      id
      name
    }
  }
  manufacturer {
    id
    name
  }
  type {
    id
    category
    name
  }
}
    `;
export const Basic_UserFragmentDoc = gql`
    fragment Basic_User on User {
  id
  username
}
    `;
export const GetActivityFeedDocument = gql`
    query getActivityFeed {
  checkIns(first: 20) {
    nodes {
      id
      rating
      review
      checkInDate
      createdAt
      author {
        ...Basic_User
      }
      product {
        ...Basic_Product
      }
    }
  }
}
    ${Basic_UserFragmentDoc}
${Basic_ProductFragmentDoc}`;
export const GetCompaniesDocument = gql`
    query getCompanies {
  companies {
    nodes {
      id
      brands {
        nodes {
          id
          name
        }
      }
      name
    }
  }
}
    `;
export const GetCompanyByIdDocument = gql`
    query getCompanyById($companyId: Int!) {
  company(id: $companyId) {
    id
    name
    brands {
      edges {
        node {
          id
          name
          products {
            edges {
              node {
                id
                name
                manufacturer {
                  id
                  name
                }
                type {
                  id
                  name
                  category
                }
              }
            }
          }
        }
      }
    }
  }
}
    `;
export const GetProductByIdDocument = gql`
    query getProductById($productId: Int!) {
  product(id: $productId) {
    brand {
      id
      name
      company {
        name
        id
      }
    }
    checkIns {
      nodes {
        id
        rating
        review
        author {
          ...Basic_User
        }
      }
    }
    name
    id
    manufacturer {
      id
      name
    }
    type {
      name
      id
      category
    }
  }
}
    ${Basic_UserFragmentDoc}`;
export const GetUserByIdDocument = gql`
    query getUserById($userId: UUID!) {
  user(id: $userId) {
    ...Basic_User
    firstName
    lastName
  }
}
    ${Basic_UserFragmentDoc}`;
export const LoginDocument = gql`
    mutation login($username: String!, $password: String!) {
  login(input: {username: $username, password: $password}) {
    user {
      ...Basic_User
    }
  }
}
    ${Basic_UserFragmentDoc}`;
export const RegisterDocument = gql`
    mutation register($username: String!, $password: String!) {
  register(input: {username: $username, password: $password}) {
    user {
      ...Basic_User
    }
  }
}
    ${Basic_UserFragmentDoc}`;
export const UpdateUserDocument = gql`
    mutation updateUser($id: UUID!, $username: String!, $firstName: ShortText!, $lastName: ShortText!) {
  updateUser(
    input: {patch: {username: $username, firstName: $firstName, lastName: $lastName}, id: $id}
  ) {
    user {
      username
      id
    }
  }
}
    `;

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    getActivityFeed(variables?: GetActivityFeedQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetActivityFeedQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetActivityFeedQuery>(GetActivityFeedDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getActivityFeed');
    },
    getCompanies(variables?: GetCompaniesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetCompaniesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetCompaniesQuery>(GetCompaniesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getCompanies');
    },
    getCompanyById(variables: GetCompanyByIdQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetCompanyByIdQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetCompanyByIdQuery>(GetCompanyByIdDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getCompanyById');
    },
    getProductById(variables: GetProductByIdQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetProductByIdQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetProductByIdQuery>(GetProductByIdDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getProductById');
    },
    getUserById(variables: GetUserByIdQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetUserByIdQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetUserByIdQuery>(GetUserByIdDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getUserById');
    },
    login(variables: LoginMutationVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<LoginMutation> {
      return withWrapper((wrappedRequestHeaders) => client.request<LoginMutation>(LoginDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'login');
    },
    register(variables: RegisterMutationVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<RegisterMutation> {
      return withWrapper((wrappedRequestHeaders) => client.request<RegisterMutation>(RegisterDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'register');
    },
    updateUser(variables: UpdateUserMutationVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<UpdateUserMutation> {
      return withWrapper((wrappedRequestHeaders) => client.request<UpdateUserMutation>(UpdateUserDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'updateUser');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;