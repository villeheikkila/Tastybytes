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
  /** Reads and enables pagination through a set of `Brand`. */
  brands: BrandsConnection;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  id: Scalars['Int'];
  isVerified: Scalars['Boolean'];
  name: Maybe<Scalars['MediumText']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Product`. */
  productsByManufacturerId: ProductsConnection;
  /** Reads a single `User` that is related to this `Company`. */
  userByCreatedBy: Maybe<User>;
};


export type CompanyBrandsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


export type CompanyProductsByManufacturerIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
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
export type QueryBrandByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
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
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
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

/** A user who can log in to the application. */
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


/** A user who can log in to the application. */
export type UserAuthoredCheckInsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserBrandsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserBrandsByUpdatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<BrandCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<BrandsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserCompaniesByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CompanyCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompaniesOrderBy>>;
};


/** A user who can log in to the application. */
export type UserProductsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserProductsByUpdatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ProductCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ProductsOrderBy>>;
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

export type LoginMutationVariables = Exact<{
  username: Scalars['String'];
  password: Scalars['String'];
}>;


export type LoginMutation = { __typename?: 'Mutation', login: { __typename?: 'LoginPayload', user: { __typename?: 'User', id: any } } };

export type GetCompaniesQueryVariables = Exact<{ [key: string]: never; }>;


export type GetCompaniesQuery = { __typename?: 'Query', companies: { __typename?: 'CompaniesConnection', nodes: Array<{ __typename?: 'Company', id: number, name: any, brands: { __typename?: 'BrandsConnection', nodes: Array<{ __typename?: 'Brand', id: number, name: any }> } }> } };

export type RegisterMutationVariables = Exact<{
  username: Scalars['String'];
  password: Scalars['String'];
}>;


export type RegisterMutation = { __typename?: 'Mutation', register: { __typename?: 'RegisterPayload', user: { __typename?: 'User', id: any } } };


export const LoginDocument = gql`
    mutation login($username: String!, $password: String!) {
  login(input: {username: $username, password: $password}) {
    user {
      id
    }
  }
}
    `;
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
export const RegisterDocument = gql`
    mutation register($username: String!, $password: String!) {
  register(input: {username: $username, password: $password}) {
    user {
      id
    }
  }
}
    `;

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    login(variables: LoginMutationVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<LoginMutation> {
      return withWrapper((wrappedRequestHeaders) => client.request<LoginMutation>(LoginDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'login');
    },
    getCompanies(variables?: GetCompaniesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetCompaniesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetCompaniesQuery>(GetCompaniesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getCompanies');
    },
    register(variables: RegisterMutationVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<RegisterMutation> {
      return withWrapper((wrappedRequestHeaders) => client.request<RegisterMutation>(RegisterDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'register');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;