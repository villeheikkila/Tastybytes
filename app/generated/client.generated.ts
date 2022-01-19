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
  /** A floating point number that requires more precision than IEEE 754 binary 64 */
  BigFloat: any;
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
  ShortText: any;
  /** A universally unique identifier as defined by [RFC 4122](https://tools.ietf.org/html/rfc4122). */
  UUID: any;
};

/** All input for the `acceptFriendRequest` mutation. */
export type AcceptFriendRequestInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  userId: InputMaybe<Scalars['UUID']>;
};

/** The output of our `acceptFriendRequest` mutation. */
export type AcceptFriendRequestPayload = {
  __typename?: 'AcceptFriendRequestPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};

export type ActivityFeed = {
  __typename?: 'ActivityFeed';
  /** Reads a single `User` that is related to this `ActivityFeed`. */
  author: Maybe<User>;
  authorId: Maybe<Scalars['UUID']>;
  checkInDate: Maybe<Scalars['Date']>;
  createdAt: Maybe<Scalars['Datetime']>;
  id: Maybe<Scalars['Int']>;
  isPublic: Maybe<Scalars['Boolean']>;
  /** Reads a single `Item` that is related to this `ActivityFeed`. */
  item: Maybe<Item>;
  itemId: Maybe<Scalars['Int']>;
  likes: Maybe<Scalars['Int']>;
  location: Maybe<Scalars['UUID']>;
  rating: Maybe<Scalars['Int']>;
  review: Maybe<Scalars['String']>;
};

/**
 * A condition to be used against `ActivityFeed` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type ActivityFeedCondition = {
  /** Checks for equality with the object’s `authorId` field. */
  authorId: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `checkInDate` field. */
  checkInDate: InputMaybe<Scalars['Date']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `isPublic` field. */
  isPublic: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `itemId` field. */
  itemId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `likes` field. */
  likes: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `location` field. */
  location: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `rating` field. */
  rating: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `review` field. */
  review: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `ActivityFeed` values. */
export type ActivityFeedsConnection = {
  __typename?: 'ActivityFeedsConnection';
  /** A list of edges which contains the `ActivityFeed` and cursor to aid in pagination. */
  edges: Array<ActivityFeedsEdge>;
  /** A list of `ActivityFeed` objects. */
  nodes: Array<Maybe<ActivityFeed>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `ActivityFeed` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `ActivityFeed` edge in the connection. */
export type ActivityFeedsEdge = {
  __typename?: 'ActivityFeedsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `ActivityFeed` at the end of the edge. */
  node: Maybe<ActivityFeed>;
};

/** Methods to use when ordering `ActivityFeed`. */
export enum ActivityFeedsOrderBy {
  AuthorIdAsc = 'AUTHOR_ID_ASC',
  AuthorIdDesc = 'AUTHOR_ID_DESC',
  CheckInDateAsc = 'CHECK_IN_DATE_ASC',
  CheckInDateDesc = 'CHECK_IN_DATE_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsPublicAsc = 'IS_PUBLIC_ASC',
  IsPublicDesc = 'IS_PUBLIC_DESC',
  ItemIdAsc = 'ITEM_ID_ASC',
  ItemIdDesc = 'ITEM_ID_DESC',
  LikesAsc = 'LIKES_ASC',
  LikesDesc = 'LIKES_DESC',
  LocationAsc = 'LOCATION_ASC',
  LocationDesc = 'LOCATION_DESC',
  Natural = 'NATURAL',
  RatingAsc = 'RATING_ASC',
  RatingDesc = 'RATING_DESC',
  ReviewAsc = 'REVIEW_ASC',
  ReviewDesc = 'REVIEW_DESC'
}

export type Brand = Node & {
  __typename?: 'Brand';
  /** Reads a single `Company` that is related to this `Brand`. */
  company: Maybe<Company>;
  companyId: Maybe<Scalars['Int']>;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  id: Scalars['Int'];
  isVerified: Maybe<Scalars['Boolean']>;
  /** Reads and enables pagination through a set of `ItemEditSuggestion`. */
  itemEditSuggestions: ItemEditSuggestionsConnection;
  /** Reads and enables pagination through a set of `Item`. */
  items: ItemsConnection;
  name: Maybe<Scalars['ShortText']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `User` that is related to this `Brand`. */
  userByCreatedBy: Maybe<User>;
};


export type BrandItemEditSuggestionsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemEditSuggestionCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};


export type BrandItemsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
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
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['ShortText']>;
};

/** An input for mutations affecting `Brand` */
export type BrandInput = {
  companyId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['ShortText']>;
};

/** Represents an update to a `Brand`. Fields that are set will be updated. */
export type BrandPatch = {
  companyId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['ShortText']>;
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
  IsVerifiedAsc = 'IS_VERIFIED_ASC',
  IsVerifiedDesc = 'IS_VERIFIED_DESC',
  NameAsc = 'NAME_ASC',
  NameDesc = 'NAME_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
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

/** Main categories for items */
export type Category = Node & {
  __typename?: 'Category';
  name: Scalars['String'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Type`. */
  typesByCategory: TypesConnection;
};


/** Main categories for items */
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

/** All input for the `changePassword` mutation. */
export type ChangePasswordInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  newPassword: Scalars['String'];
  oldPassword: Scalars['String'];
};

/** The output of our `changePassword` mutation. */
export type ChangePasswordPayload = {
  __typename?: 'ChangePasswordPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  success: Maybe<Scalars['Boolean']>;
};

/** Check-in is a review given to an item */
export type CheckIn = Node & {
  __typename?: 'CheckIn';
  /** Reads a single `User` that is related to this `CheckIn`. */
  author: Maybe<User>;
  authorId: Scalars['UUID'];
  /** Reads and enables pagination through a set of `CheckInComment`. */
  checkInComments: CheckInCommentsConnection;
  checkInDate: Maybe<Scalars['Date']>;
  /** Reads and enables pagination through a set of `CheckInFriend`. */
  checkInFriends: CheckInFriendsConnection;
  /** Reads a single `CheckInLike` that is related to this `CheckIn`. */
  checkInLikeById: Maybe<CheckInLike>;
  /**
   * Reads and enables pagination through a set of `CheckInLike`.
   * @deprecated Please use checkInLikeById instead
   */
  checkInLikesById: CheckInLikesConnection;
  /** Reads and enables pagination through a set of `CheckInTag`. */
  checkInTags: CheckInTagsConnection;
  createdAt: Scalars['Datetime'];
  id: Scalars['Int'];
  isPublic: Maybe<Scalars['Boolean']>;
  /** Reads a single `Item` that is related to this `CheckIn`. */
  item: Maybe<Item>;
  itemId: Scalars['Int'];
  likes: Maybe<Scalars['Int']>;
  location: Maybe<Scalars['UUID']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  rating: Maybe<Scalars['Int']>;
  review: Maybe<Scalars['String']>;
};


/** Check-in is a review given to an item */
export type CheckInCheckInCommentsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCommentCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInCommentsOrderBy>>;
};


/** Check-in is a review given to an item */
export type CheckInCheckInFriendsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInFriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInFriendsOrderBy>>;
};


/** Check-in is a review given to an item */
export type CheckInCheckInLikesByIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInLikeCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInLikesOrderBy>>;
};


/** Check-in is a review given to an item */
export type CheckInCheckInTagsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInTagCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInTagsOrderBy>>;
};

export type CheckInComment = Node & {
  __typename?: 'CheckInComment';
  /** Reads a single `CheckIn` that is related to this `CheckInComment`. */
  checkIn: Maybe<CheckIn>;
  checkInId: Scalars['Int'];
  comment: Maybe<Scalars['LongText']>;
  createdAt: Scalars['Datetime'];
  createdBy: Scalars['UUID'];
  id: Scalars['Int'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `User` that is related to this `CheckInComment`. */
  userByCreatedBy: Maybe<User>;
};

/**
 * A condition to be used against `CheckInComment` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type CheckInCommentCondition = {
  /** Checks for equality with the object’s `checkInId` field. */
  checkInId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `comment` field. */
  comment: InputMaybe<Scalars['LongText']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `createdBy` field. */
  createdBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
};

/** An input for mutations affecting `CheckInComment` */
export type CheckInCommentInput = {
  checkInId: Scalars['Int'];
  comment: InputMaybe<Scalars['LongText']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: Scalars['UUID'];
  id: InputMaybe<Scalars['Int']>;
};

/** Represents an update to a `CheckInComment`. Fields that are set will be updated. */
export type CheckInCommentPatch = {
  checkInId: InputMaybe<Scalars['Int']>;
  comment: InputMaybe<Scalars['LongText']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
};

/** A connection to a list of `CheckInComment` values. */
export type CheckInCommentsConnection = {
  __typename?: 'CheckInCommentsConnection';
  /** A list of edges which contains the `CheckInComment` and cursor to aid in pagination. */
  edges: Array<CheckInCommentsEdge>;
  /** A list of `CheckInComment` objects. */
  nodes: Array<Maybe<CheckInComment>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CheckInComment` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CheckInComment` edge in the connection. */
export type CheckInCommentsEdge = {
  __typename?: 'CheckInCommentsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CheckInComment` at the end of the edge. */
  node: Maybe<CheckInComment>;
};

/** Methods to use when ordering `CheckInComment`. */
export enum CheckInCommentsOrderBy {
  CheckInIdAsc = 'CHECK_IN_ID_ASC',
  CheckInIdDesc = 'CHECK_IN_ID_DESC',
  CommentAsc = 'COMMENT_ASC',
  CommentDesc = 'COMMENT_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  CreatedByAsc = 'CREATED_BY_ASC',
  CreatedByDesc = 'CREATED_BY_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

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
  /** Checks for equality with the object’s `isPublic` field. */
  isPublic: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `itemId` field. */
  itemId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `likes` field. */
  likes: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `location` field. */
  location: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `rating` field. */
  rating: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `review` field. */
  review: InputMaybe<Scalars['String']>;
};

export type CheckInFriend = {
  __typename?: 'CheckInFriend';
  /** Reads a single `CheckIn` that is related to this `CheckInFriend`. */
  checkIn: Maybe<CheckIn>;
  checkInId: Maybe<Scalars['Int']>;
  /** Reads a single `User` that is related to this `CheckInFriend`. */
  friend: Maybe<User>;
  friendId: Maybe<Scalars['UUID']>;
};

/**
 * A condition to be used against `CheckInFriend` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type CheckInFriendCondition = {
  /** Checks for equality with the object’s `checkInId` field. */
  checkInId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `friendId` field. */
  friendId: InputMaybe<Scalars['UUID']>;
};

/** An input for mutations affecting `CheckInFriend` */
export type CheckInFriendInput = {
  checkInId: InputMaybe<Scalars['Int']>;
  friendId: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `CheckInFriend` values. */
export type CheckInFriendsConnection = {
  __typename?: 'CheckInFriendsConnection';
  /** A list of edges which contains the `CheckInFriend` and cursor to aid in pagination. */
  edges: Array<CheckInFriendsEdge>;
  /** A list of `CheckInFriend` objects. */
  nodes: Array<Maybe<CheckInFriend>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CheckInFriend` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CheckInFriend` edge in the connection. */
export type CheckInFriendsEdge = {
  __typename?: 'CheckInFriendsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CheckInFriend` at the end of the edge. */
  node: Maybe<CheckInFriend>;
};

/** Methods to use when ordering `CheckInFriend`. */
export enum CheckInFriendsOrderBy {
  CheckInIdAsc = 'CHECK_IN_ID_ASC',
  CheckInIdDesc = 'CHECK_IN_ID_DESC',
  FriendIdAsc = 'FRIEND_ID_ASC',
  FriendIdDesc = 'FRIEND_ID_DESC',
  Natural = 'NATURAL'
}

/** An input for mutations affecting `CheckIn` */
export type CheckInInput = {
  authorId: Scalars['UUID'];
  checkInDate: InputMaybe<Scalars['Date']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['Int']>;
  isPublic: InputMaybe<Scalars['Boolean']>;
  itemId: Scalars['Int'];
  likes: InputMaybe<Scalars['Int']>;
  location: InputMaybe<Scalars['UUID']>;
  rating: InputMaybe<Scalars['Int']>;
  review: InputMaybe<Scalars['String']>;
};

export type CheckInLike = Node & {
  __typename?: 'CheckInLike';
  /** Reads a single `CheckIn` that is related to this `CheckInLike`. */
  checkInById: Maybe<CheckIn>;
  id: Scalars['Int'];
  likedBy: Maybe<Scalars['UUID']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `User` that is related to this `CheckInLike`. */
  userByLikedBy: Maybe<User>;
};

/**
 * A condition to be used against `CheckInLike` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type CheckInLikeCondition = {
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `likedBy` field. */
  likedBy: InputMaybe<Scalars['UUID']>;
};

/** An input for mutations affecting `CheckInLike` */
export type CheckInLikeInput = {
  id: InputMaybe<Scalars['Int']>;
  likedBy: InputMaybe<Scalars['UUID']>;
};

/** Represents an update to a `CheckInLike`. Fields that are set will be updated. */
export type CheckInLikePatch = {
  id: InputMaybe<Scalars['Int']>;
  likedBy: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `CheckInLike` values. */
export type CheckInLikesConnection = {
  __typename?: 'CheckInLikesConnection';
  /** A list of edges which contains the `CheckInLike` and cursor to aid in pagination. */
  edges: Array<CheckInLikesEdge>;
  /** A list of `CheckInLike` objects. */
  nodes: Array<Maybe<CheckInLike>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CheckInLike` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CheckInLike` edge in the connection. */
export type CheckInLikesEdge = {
  __typename?: 'CheckInLikesEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CheckInLike` at the end of the edge. */
  node: Maybe<CheckInLike>;
};

/** Methods to use when ordering `CheckInLike`. */
export enum CheckInLikesOrderBy {
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  LikedByAsc = 'LIKED_BY_ASC',
  LikedByDesc = 'LIKED_BY_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

/** Represents an update to a `CheckIn`. Fields that are set will be updated. */
export type CheckInPatch = {
  authorId: InputMaybe<Scalars['UUID']>;
  checkInDate: InputMaybe<Scalars['Date']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['Int']>;
  isPublic: InputMaybe<Scalars['Boolean']>;
  itemId: InputMaybe<Scalars['Int']>;
  likes: InputMaybe<Scalars['Int']>;
  location: InputMaybe<Scalars['UUID']>;
  rating: InputMaybe<Scalars['Int']>;
  review: InputMaybe<Scalars['String']>;
};

export type CheckInTag = Node & {
  __typename?: 'CheckInTag';
  /** Reads a single `CheckIn` that is related to this `CheckInTag`. */
  checkIn: Maybe<CheckIn>;
  checkInId: Scalars['Int'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `Tag` that is related to this `CheckInTag`. */
  tag: Maybe<Tag>;
  tagId: Scalars['Int'];
};

/**
 * A condition to be used against `CheckInTag` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type CheckInTagCondition = {
  /** Checks for equality with the object’s `checkInId` field. */
  checkInId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `tagId` field. */
  tagId: InputMaybe<Scalars['Int']>;
};

/** An input for mutations affecting `CheckInTag` */
export type CheckInTagInput = {
  checkInId: Scalars['Int'];
  tagId: Scalars['Int'];
};

/** Represents an update to a `CheckInTag`. Fields that are set will be updated. */
export type CheckInTagPatch = {
  checkInId: InputMaybe<Scalars['Int']>;
  tagId: InputMaybe<Scalars['Int']>;
};

/** A connection to a list of `CheckInTag` values. */
export type CheckInTagsConnection = {
  __typename?: 'CheckInTagsConnection';
  /** A list of edges which contains the `CheckInTag` and cursor to aid in pagination. */
  edges: Array<CheckInTagsEdge>;
  /** A list of `CheckInTag` objects. */
  nodes: Array<Maybe<CheckInTag>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CheckInTag` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CheckInTag` edge in the connection. */
export type CheckInTagsEdge = {
  __typename?: 'CheckInTagsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CheckInTag` at the end of the edge. */
  node: Maybe<CheckInTag>;
};

/** Methods to use when ordering `CheckInTag`. */
export enum CheckInTagsOrderBy {
  CheckInIdAsc = 'CHECK_IN_ID_ASC',
  CheckInIdDesc = 'CHECK_IN_ID_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  TagIdAsc = 'TAG_ID_ASC',
  TagIdDesc = 'TAG_ID_DESC'
}

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
  IsPublicAsc = 'IS_PUBLIC_ASC',
  IsPublicDesc = 'IS_PUBLIC_DESC',
  ItemIdAsc = 'ITEM_ID_ASC',
  ItemIdDesc = 'ITEM_ID_DESC',
  LikesAsc = 'LIKES_ASC',
  LikesDesc = 'LIKES_DESC',
  LocationAsc = 'LOCATION_ASC',
  LocationDesc = 'LOCATION_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  RatingAsc = 'RATING_ASC',
  RatingDesc = 'RATING_DESC',
  ReviewAsc = 'REVIEW_ASC',
  ReviewDesc = 'REVIEW_DESC'
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
  DescriptionAsc = 'DESCRIPTION_ASC',
  DescriptionDesc = 'DESCRIPTION_DESC',
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
  /** Reads and enables pagination through a set of `CompanyLike`. */
  companyLikesById: CompanyLikesConnection;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  currentUserCheckIns: Maybe<Scalars['Int']>;
  description: Maybe<Scalars['LongText']>;
  id: Scalars['Int'];
  isVerified: Scalars['Boolean'];
  /** Reads and enables pagination through a set of `ItemEditSuggestion`. */
  itemEditSuggestionsByManufacturerId: ItemEditSuggestionsConnection;
  /** Reads and enables pagination through a set of `Item`. */
  itemsByManufacturerId: ItemsConnection;
  name: Scalars['String'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  totalCheckIns: Maybe<Scalars['Int']>;
  totalItems: Maybe<Scalars['Int']>;
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


export type CompanyCompanyLikesByIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CompanyLikeCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompanyLikesOrderBy>>;
};


export type CompanyItemEditSuggestionsByManufacturerIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemEditSuggestionCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};


export type CompanyItemsByManufacturerIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};

/** A condition to be used against `Company` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type CompanyCondition = {
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
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['String']>;
};

/** An input for mutations affecting `Company` */
export type CompanyInput = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  description: InputMaybe<Scalars['LongText']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: Scalars['String'];
};

export type CompanyLike = Node & {
  __typename?: 'CompanyLike';
  /** Reads a single `Company` that is related to this `CompanyLike`. */
  companyById: Maybe<Company>;
  id: Scalars['Int'];
  likedBy: Scalars['UUID'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `User` that is related to this `CompanyLike`. */
  userByLikedBy: Maybe<User>;
};

/**
 * A condition to be used against `CompanyLike` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type CompanyLikeCondition = {
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `likedBy` field. */
  likedBy: InputMaybe<Scalars['UUID']>;
};

/** An input for mutations affecting `CompanyLike` */
export type CompanyLikeInput = {
  id: Scalars['Int'];
  likedBy: Scalars['UUID'];
};

/** Represents an update to a `CompanyLike`. Fields that are set will be updated. */
export type CompanyLikePatch = {
  id: InputMaybe<Scalars['Int']>;
  likedBy: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `CompanyLike` values. */
export type CompanyLikesConnection = {
  __typename?: 'CompanyLikesConnection';
  /** A list of edges which contains the `CompanyLike` and cursor to aid in pagination. */
  edges: Array<CompanyLikesEdge>;
  /** A list of `CompanyLike` objects. */
  nodes: Array<Maybe<CompanyLike>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CompanyLike` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CompanyLike` edge in the connection. */
export type CompanyLikesEdge = {
  __typename?: 'CompanyLikesEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CompanyLike` at the end of the edge. */
  node: Maybe<CompanyLike>;
};

/** Methods to use when ordering `CompanyLike`. */
export enum CompanyLikesOrderBy {
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  LikedByAsc = 'LIKED_BY_ASC',
  LikedByDesc = 'LIKED_BY_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

/** Represents an update to a `Company`. Fields that are set will be updated. */
export type CompanyPatch = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  description: InputMaybe<Scalars['LongText']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['String']>;
};

/** All input for the `confirmAccountDeletion` mutation. */
export type ConfirmAccountDeletionInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  token: Scalars['String'];
};

/** The output of our `confirmAccountDeletion` mutation. */
export type ConfirmAccountDeletionPayload = {
  __typename?: 'ConfirmAccountDeletionPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  success: Maybe<Scalars['Boolean']>;
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

/** All input for the create `CheckInComment` mutation. */
export type CreateCheckInCommentInput = {
  /** The `CheckInComment` to be created by this mutation. */
  checkInComment: CheckInCommentInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `CheckInComment` mutation. */
export type CreateCheckInCommentPayload = {
  __typename?: 'CreateCheckInCommentPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInComment`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInComment` that was created by this mutation. */
  checkInComment: Maybe<CheckInComment>;
  /** An edge for our `CheckInComment`. May be used by Relay 1. */
  checkInCommentEdge: Maybe<CheckInCommentsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CheckInComment`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our create `CheckInComment` mutation. */
export type CreateCheckInCommentPayloadCheckInCommentEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInCommentsOrderBy>>;
};

/** All input for the create `CheckInFriend` mutation. */
export type CreateCheckInFriendInput = {
  /** The `CheckInFriend` to be created by this mutation. */
  checkInFriend: CheckInFriendInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `CheckInFriend` mutation. */
export type CreateCheckInFriendPayload = {
  __typename?: 'CreateCheckInFriendPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInFriend`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInFriend` that was created by this mutation. */
  checkInFriend: Maybe<CheckInFriend>;
  /** An edge for our `CheckInFriend`. May be used by Relay 1. */
  checkInFriendEdge: Maybe<CheckInFriendsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `User` that is related to this `CheckInFriend`. */
  friend: Maybe<User>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our create `CheckInFriend` mutation. */
export type CreateCheckInFriendPayloadCheckInFriendEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInFriendsOrderBy>>;
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

/** All input for the create `CheckInLike` mutation. */
export type CreateCheckInLikeInput = {
  /** The `CheckInLike` to be created by this mutation. */
  checkInLike: CheckInLikeInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `CheckInLike` mutation. */
export type CreateCheckInLikePayload = {
  __typename?: 'CreateCheckInLikePayload';
  /** Reads a single `CheckIn` that is related to this `CheckInLike`. */
  checkInById: Maybe<CheckIn>;
  /** The `CheckInLike` that was created by this mutation. */
  checkInLike: Maybe<CheckInLike>;
  /** An edge for our `CheckInLike`. May be used by Relay 1. */
  checkInLikeEdge: Maybe<CheckInLikesEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CheckInLike`. */
  userByLikedBy: Maybe<User>;
};


/** The output of our create `CheckInLike` mutation. */
export type CreateCheckInLikePayloadCheckInLikeEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInLikesOrderBy>>;
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
  /** Reads a single `Item` that is related to this `CheckIn`. */
  item: Maybe<Item>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our create `CheckIn` mutation. */
export type CreateCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the create `CheckInTag` mutation. */
export type CreateCheckInTagInput = {
  /** The `CheckInTag` to be created by this mutation. */
  checkInTag: CheckInTagInput;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our create `CheckInTag` mutation. */
export type CreateCheckInTagPayload = {
  __typename?: 'CreateCheckInTagPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInTag`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInTag` that was created by this mutation. */
  checkInTag: Maybe<CheckInTag>;
  /** An edge for our `CheckInTag`. May be used by Relay 1. */
  checkInTagEdge: Maybe<CheckInTagsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Tag` that is related to this `CheckInTag`. */
  tag: Maybe<Tag>;
};


/** The output of our create `CheckInTag` mutation. */
export type CreateCheckInTagPayloadCheckInTagEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInTagsOrderBy>>;
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

/** All input for the create `CompanyLike` mutation. */
export type CreateCompanyLikeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `CompanyLike` to be created by this mutation. */
  companyLike: CompanyLikeInput;
};

/** The output of our create `CompanyLike` mutation. */
export type CreateCompanyLikePayload = {
  __typename?: 'CreateCompanyLikePayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `CompanyLike`. */
  companyById: Maybe<Company>;
  /** The `CompanyLike` that was created by this mutation. */
  companyLike: Maybe<CompanyLike>;
  /** An edge for our `CompanyLike`. May be used by Relay 1. */
  companyLikeEdge: Maybe<CompanyLikesEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CompanyLike`. */
  userByLikedBy: Maybe<User>;
};


/** The output of our create `CompanyLike` mutation. */
export type CreateCompanyLikePayloadCompanyLikeEdgeArgs = {
  orderBy?: InputMaybe<Array<CompanyLikesOrderBy>>;
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

/** All input for the create `Friend` mutation. */
export type CreateFriendInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `Friend` to be created by this mutation. */
  friend: FriendInput;
};

/** The output of our create `Friend` mutation. */
export type CreateFriendPayload = {
  __typename?: 'CreateFriendPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Friend` that was created by this mutation. */
  friend: Maybe<Friend>;
  /** An edge for our `Friend`. May be used by Relay 1. */
  friendEdge: Maybe<FriendsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByBlockedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId1: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId2: Maybe<User>;
};


/** The output of our create `Friend` mutation. */
export type CreateFriendPayloadFriendEdgeArgs = {
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};

/** All input for the `createFriendRequest` mutation. */
export type CreateFriendRequestInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  userId: InputMaybe<Scalars['UUID']>;
};

/** The output of our `createFriendRequest` mutation. */
export type CreateFriendRequestPayload = {
  __typename?: 'CreateFriendRequestPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};

/** All input for the create `ItemEditSuggestion` mutation. */
export type CreateItemEditSuggestionInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `ItemEditSuggestion` to be created by this mutation. */
  itemEditSuggestion: ItemEditSuggestionInput;
};

/** The output of our create `ItemEditSuggestion` mutation. */
export type CreateItemEditSuggestionPayload = {
  __typename?: 'CreateItemEditSuggestionPayload';
  /** Reads a single `User` that is related to this `ItemEditSuggestion`. */
  author: Maybe<User>;
  /** Reads a single `Brand` that is related to this `ItemEditSuggestion`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Item` that is related to this `ItemEditSuggestion`. */
  item: Maybe<Item>;
  /** The `ItemEditSuggestion` that was created by this mutation. */
  itemEditSuggestion: Maybe<ItemEditSuggestion>;
  /** An edge for our `ItemEditSuggestion`. May be used by Relay 1. */
  itemEditSuggestionEdge: Maybe<ItemEditSuggestionsEdge>;
  /** Reads a single `Company` that is related to this `ItemEditSuggestion`. */
  manufacturer: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `ItemEditSuggestion`. */
  type: Maybe<Type>;
};


/** The output of our create `ItemEditSuggestion` mutation. */
export type CreateItemEditSuggestionPayloadItemEditSuggestionEdgeArgs = {
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};

/** All input for the create `Item` mutation. */
export type CreateItemInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `Item` to be created by this mutation. */
  item: ItemInput;
};

/** The output of our create `Item` mutation. */
export type CreateItemPayload = {
  __typename?: 'CreateItemPayload';
  /** Reads a single `Brand` that is related to this `Item`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Item` that was created by this mutation. */
  item: Maybe<Item>;
  /** An edge for our `Item`. May be used by Relay 1. */
  itemEdge: Maybe<ItemsEdge>;
  /** Reads a single `Company` that is related to this `Item`. */
  manufacturer: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `Item`. */
  type: Maybe<Type>;
  /** Reads a single `User` that is related to this `Item`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Item`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our create `Item` mutation. */
export type CreateItemPayloadItemEdgeArgs = {
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};

/** All input for the create `PublicCheckIn` mutation. */
export type CreatePublicCheckInInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `PublicCheckIn` to be created by this mutation. */
  publicCheckIn: PublicCheckInInput;
};

/** The output of our create `PublicCheckIn` mutation. */
export type CreatePublicCheckInPayload = {
  __typename?: 'CreatePublicCheckInPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `PublicCheckIn` that was created by this mutation. */
  publicCheckIn: Maybe<PublicCheckIn>;
  /** An edge for our `PublicCheckIn`. May be used by Relay 1. */
  publicCheckInEdge: Maybe<PublicCheckInsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our create `PublicCheckIn` mutation. */
export type CreatePublicCheckInPayloadPublicCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<PublicCheckInsOrderBy>>;
};

/** All input for the create `Tag` mutation. */
export type CreateTagInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `Tag` to be created by this mutation. */
  tag: TagInput;
};

/** The output of our create `Tag` mutation. */
export type CreateTagPayload = {
  __typename?: 'CreateTagPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `Tag` that was created by this mutation. */
  tag: Maybe<Tag>;
  /** An edge for our `Tag`. May be used by Relay 1. */
  tagEdge: Maybe<TagsEdge>;
  /** Reads a single `User` that is related to this `Tag`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our create `Tag` mutation. */
export type CreateTagPayloadTagEdgeArgs = {
  orderBy?: InputMaybe<Array<TagsOrderBy>>;
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

/** All input for the create `UserAuthentication` mutation. */
export type CreateUserAuthenticationInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `UserAuthentication` to be created by this mutation. */
  userAuthentication: UserAuthenticationInput;
};

/** The output of our create `UserAuthentication` mutation. */
export type CreateUserAuthenticationPayload = {
  __typename?: 'CreateUserAuthenticationPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserAuthentication`. */
  user: Maybe<User>;
  /** The `UserAuthentication` that was created by this mutation. */
  userAuthentication: Maybe<UserAuthentication>;
};

/** All input for the create `UserEmail` mutation. */
export type CreateUserEmailInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `UserEmail` to be created by this mutation. */
  userEmail: UserEmailInput;
};

/** The output of our create `UserEmail` mutation. */
export type CreateUserEmailPayload = {
  __typename?: 'CreateUserEmailPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserEmail`. */
  user: Maybe<User>;
  /** The `UserEmail` that was created by this mutation. */
  userEmail: Maybe<UserEmail>;
  /** An edge for our `UserEmail`. May be used by Relay 1. */
  userEmailEdge: Maybe<UserEmailsEdge>;
};


/** The output of our create `UserEmail` mutation. */
export type CreateUserEmailPayloadUserEmailEdgeArgs = {
  orderBy?: InputMaybe<Array<UserEmailsOrderBy>>;
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

/** All input for the create `UserSetting` mutation. */
export type CreateUserSettingInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The `UserSetting` to be created by this mutation. */
  userSetting: UserSettingInput;
};

/** The output of our create `UserSetting` mutation. */
export type CreateUserSettingPayload = {
  __typename?: 'CreateUserSettingPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserSetting`. */
  userById: Maybe<User>;
  /** The `UserSetting` that was created by this mutation. */
  userSetting: Maybe<UserSetting>;
  /** An edge for our `UserSetting`. May be used by Relay 1. */
  userSettingEdge: Maybe<UserSettingsEdge>;
};


/** The output of our create `UserSetting` mutation. */
export type CreateUserSettingPayloadUserSettingEdgeArgs = {
  orderBy?: InputMaybe<Array<UserSettingsOrderBy>>;
};

export type CurrentUserFriend = {
  __typename?: 'CurrentUserFriend';
  avatarUrl: Maybe<Scalars['String']>;
  firstName: Maybe<Scalars['String']>;
  id: Maybe<Scalars['Int']>;
  lastName: Maybe<Scalars['String']>;
  status: Maybe<FriendStatus>;
  userId: Maybe<Scalars['UUID']>;
  username: Maybe<Scalars['String']>;
};

/**
 * A condition to be used against `CurrentUserFriend` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type CurrentUserFriendCondition = {
  /** Checks for equality with the object’s `avatarUrl` field. */
  avatarUrl: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `firstName` field. */
  firstName: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `lastName` field. */
  lastName: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `status` field. */
  status: InputMaybe<FriendStatus>;
  /** Checks for equality with the object’s `userId` field. */
  userId: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `username` field. */
  username: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `CurrentUserFriend` values. */
export type CurrentUserFriendsConnection = {
  __typename?: 'CurrentUserFriendsConnection';
  /** A list of edges which contains the `CurrentUserFriend` and cursor to aid in pagination. */
  edges: Array<CurrentUserFriendsEdge>;
  /** A list of `CurrentUserFriend` objects. */
  nodes: Array<Maybe<CurrentUserFriend>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `CurrentUserFriend` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `CurrentUserFriend` edge in the connection. */
export type CurrentUserFriendsEdge = {
  __typename?: 'CurrentUserFriendsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `CurrentUserFriend` at the end of the edge. */
  node: Maybe<CurrentUserFriend>;
};

/** Methods to use when ordering `CurrentUserFriend`. */
export enum CurrentUserFriendsOrderBy {
  AvatarUrlAsc = 'AVATAR_URL_ASC',
  AvatarUrlDesc = 'AVATAR_URL_DESC',
  FirstNameAsc = 'FIRST_NAME_ASC',
  FirstNameDesc = 'FIRST_NAME_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  LastNameAsc = 'LAST_NAME_ASC',
  LastNameDesc = 'LAST_NAME_DESC',
  Natural = 'NATURAL',
  StatusAsc = 'STATUS_ASC',
  StatusDesc = 'STATUS_DESC',
  UsernameAsc = 'USERNAME_ASC',
  UsernameDesc = 'USERNAME_DESC',
  UserIdAsc = 'USER_ID_ASC',
  UserIdDesc = 'USER_ID_DESC'
}

/** All input for the `deleteBrandByCompanyIdAndName` mutation. */
export type DeleteBrandByCompanyIdAndNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  companyId: Scalars['Int'];
  name: Scalars['ShortText'];
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

/** All input for the `deleteCheckInCommentByNodeId` mutation. */
export type DeleteCheckInCommentByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckInComment` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCheckInComment` mutation. */
export type DeleteCheckInCommentInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `CheckInComment` mutation. */
export type DeleteCheckInCommentPayload = {
  __typename?: 'DeleteCheckInCommentPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInComment`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInComment` that was deleted by this mutation. */
  checkInComment: Maybe<CheckInComment>;
  /** An edge for our `CheckInComment`. May be used by Relay 1. */
  checkInCommentEdge: Maybe<CheckInCommentsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedCheckInCommentNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CheckInComment`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our delete `CheckInComment` mutation. */
export type DeleteCheckInCommentPayloadCheckInCommentEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInCommentsOrderBy>>;
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

/** All input for the `deleteCheckInLikeByNodeId` mutation. */
export type DeleteCheckInLikeByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckInLike` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCheckInLike` mutation. */
export type DeleteCheckInLikeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `CheckInLike` mutation. */
export type DeleteCheckInLikePayload = {
  __typename?: 'DeleteCheckInLikePayload';
  /** Reads a single `CheckIn` that is related to this `CheckInLike`. */
  checkInById: Maybe<CheckIn>;
  /** The `CheckInLike` that was deleted by this mutation. */
  checkInLike: Maybe<CheckInLike>;
  /** An edge for our `CheckInLike`. May be used by Relay 1. */
  checkInLikeEdge: Maybe<CheckInLikesEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedCheckInLikeNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CheckInLike`. */
  userByLikedBy: Maybe<User>;
};


/** The output of our delete `CheckInLike` mutation. */
export type DeleteCheckInLikePayloadCheckInLikeEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInLikesOrderBy>>;
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
  /** Reads a single `Item` that is related to this `CheckIn`. */
  item: Maybe<Item>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our delete `CheckIn` mutation. */
export type DeleteCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the `deleteCheckInTagByNodeId` mutation. */
export type DeleteCheckInTagByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckInTag` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCheckInTag` mutation. */
export type DeleteCheckInTagInput = {
  checkInId: Scalars['Int'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  tagId: Scalars['Int'];
};

/** The output of our delete `CheckInTag` mutation. */
export type DeleteCheckInTagPayload = {
  __typename?: 'DeleteCheckInTagPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInTag`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInTag` that was deleted by this mutation. */
  checkInTag: Maybe<CheckInTag>;
  /** An edge for our `CheckInTag`. May be used by Relay 1. */
  checkInTagEdge: Maybe<CheckInTagsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedCheckInTagNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Tag` that is related to this `CheckInTag`. */
  tag: Maybe<Tag>;
};


/** The output of our delete `CheckInTag` mutation. */
export type DeleteCheckInTagPayloadCheckInTagEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInTagsOrderBy>>;
};

/** All input for the `deleteCompanyByName` mutation. */
export type DeleteCompanyByNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
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

/** All input for the `deleteCompanyLikeByNodeId` mutation. */
export type DeleteCompanyLikeByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CompanyLike` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteCompanyLike` mutation. */
export type DeleteCompanyLikeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  likedBy: Scalars['UUID'];
};

/** The output of our delete `CompanyLike` mutation. */
export type DeleteCompanyLikePayload = {
  __typename?: 'DeleteCompanyLikePayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `CompanyLike`. */
  companyById: Maybe<Company>;
  /** The `CompanyLike` that was deleted by this mutation. */
  companyLike: Maybe<CompanyLike>;
  /** An edge for our `CompanyLike`. May be used by Relay 1. */
  companyLikeEdge: Maybe<CompanyLikesEdge>;
  deletedCompanyLikeNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CompanyLike`. */
  userByLikedBy: Maybe<User>;
};


/** The output of our delete `CompanyLike` mutation. */
export type DeleteCompanyLikePayloadCompanyLikeEdgeArgs = {
  orderBy?: InputMaybe<Array<CompanyLikesOrderBy>>;
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

/** All input for the `deleteFriendByNodeId` mutation. */
export type DeleteFriendByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Friend` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteFriend` mutation. */
export type DeleteFriendInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  userId1: Scalars['UUID'];
  userId2: Scalars['UUID'];
};

/** The output of our delete `Friend` mutation. */
export type DeleteFriendPayload = {
  __typename?: 'DeleteFriendPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedFriendNodeId: Maybe<Scalars['ID']>;
  /** The `Friend` that was deleted by this mutation. */
  friend: Maybe<Friend>;
  /** An edge for our `Friend`. May be used by Relay 1. */
  friendEdge: Maybe<FriendsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByBlockedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId1: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId2: Maybe<User>;
};


/** The output of our delete `Friend` mutation. */
export type DeleteFriendPayloadFriendEdgeArgs = {
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};

/** All input for the `deleteItemByBrandIdAndFlavor` mutation. */
export type DeleteItemByBrandIdAndFlavorInput = {
  brandId: Scalars['Int'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  flavor: Scalars['String'];
};

/** All input for the `deleteItemByNodeId` mutation. */
export type DeleteItemByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Item` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteItemEditSuggestionByNodeId` mutation. */
export type DeleteItemEditSuggestionByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `ItemEditSuggestion` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteItemEditSuggestion` mutation. */
export type DeleteItemEditSuggestionInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `ItemEditSuggestion` mutation. */
export type DeleteItemEditSuggestionPayload = {
  __typename?: 'DeleteItemEditSuggestionPayload';
  /** Reads a single `User` that is related to this `ItemEditSuggestion`. */
  author: Maybe<User>;
  /** Reads a single `Brand` that is related to this `ItemEditSuggestion`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedItemEditSuggestionNodeId: Maybe<Scalars['ID']>;
  /** Reads a single `Item` that is related to this `ItemEditSuggestion`. */
  item: Maybe<Item>;
  /** The `ItemEditSuggestion` that was deleted by this mutation. */
  itemEditSuggestion: Maybe<ItemEditSuggestion>;
  /** An edge for our `ItemEditSuggestion`. May be used by Relay 1. */
  itemEditSuggestionEdge: Maybe<ItemEditSuggestionsEdge>;
  /** Reads a single `Company` that is related to this `ItemEditSuggestion`. */
  manufacturer: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `ItemEditSuggestion`. */
  type: Maybe<Type>;
};


/** The output of our delete `ItemEditSuggestion` mutation. */
export type DeleteItemEditSuggestionPayloadItemEditSuggestionEdgeArgs = {
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};

/** All input for the `deleteItem` mutation. */
export type DeleteItemInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `Item` mutation. */
export type DeleteItemPayload = {
  __typename?: 'DeleteItemPayload';
  /** Reads a single `Brand` that is related to this `Item`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedItemNodeId: Maybe<Scalars['ID']>;
  /** The `Item` that was deleted by this mutation. */
  item: Maybe<Item>;
  /** An edge for our `Item`. May be used by Relay 1. */
  itemEdge: Maybe<ItemsEdge>;
  /** Reads a single `Company` that is related to this `Item`. */
  manufacturer: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `Item`. */
  type: Maybe<Type>;
  /** Reads a single `User` that is related to this `Item`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Item`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our delete `Item` mutation. */
export type DeleteItemPayloadItemEdgeArgs = {
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};

/** All input for the `deleteTagByName` mutation. */
export type DeleteTagByNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
};

/** All input for the `deleteTagByNodeId` mutation. */
export type DeleteTagByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Tag` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteTag` mutation. */
export type DeleteTagInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
};

/** The output of our delete `Tag` mutation. */
export type DeleteTagPayload = {
  __typename?: 'DeleteTagPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedTagNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `Tag` that was deleted by this mutation. */
  tag: Maybe<Tag>;
  /** An edge for our `Tag`. May be used by Relay 1. */
  tagEdge: Maybe<TagsEdge>;
  /** Reads a single `User` that is related to this `Tag`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our delete `Tag` mutation. */
export type DeleteTagPayloadTagEdgeArgs = {
  orderBy?: InputMaybe<Array<TagsOrderBy>>;
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

/** All input for the `deleteUserAuthenticationByNodeId` mutation. */
export type DeleteUserAuthenticationByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `UserAuthentication` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteUserAuthentication` mutation. */
export type DeleteUserAuthenticationInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
};

/** The output of our delete `UserAuthentication` mutation. */
export type DeleteUserAuthenticationPayload = {
  __typename?: 'DeleteUserAuthenticationPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedUserAuthenticationNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserAuthentication`. */
  user: Maybe<User>;
  /** The `UserAuthentication` that was deleted by this mutation. */
  userAuthentication: Maybe<UserAuthentication>;
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
  /** Public-facing username (or 'handle') of the user. */
  username: Scalars['String'];
};

/** All input for the `deleteUserEmailByNodeId` mutation. */
export type DeleteUserEmailByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `UserEmail` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteUserEmail` mutation. */
export type DeleteUserEmailInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
};

/** The output of our delete `UserEmail` mutation. */
export type DeleteUserEmailPayload = {
  __typename?: 'DeleteUserEmailPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedUserEmailNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserEmail`. */
  user: Maybe<User>;
  /** The `UserEmail` that was deleted by this mutation. */
  userEmail: Maybe<UserEmail>;
  /** An edge for our `UserEmail`. May be used by Relay 1. */
  userEmailEdge: Maybe<UserEmailsEdge>;
};


/** The output of our delete `UserEmail` mutation. */
export type DeleteUserEmailPayloadUserEmailEdgeArgs = {
  orderBy?: InputMaybe<Array<UserEmailsOrderBy>>;
};

/** All input for the `deleteUser` mutation. */
export type DeleteUserInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** Unique identifier for the user. */
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

/** All input for the `deleteUserSettingByNodeId` mutation. */
export type DeleteUserSettingByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `UserSetting` to be deleted. */
  nodeId: Scalars['ID'];
};

/** All input for the `deleteUserSetting` mutation. */
export type DeleteUserSettingInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
};

/** The output of our delete `UserSetting` mutation. */
export type DeleteUserSettingPayload = {
  __typename?: 'DeleteUserSettingPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  deletedUserSettingNodeId: Maybe<Scalars['ID']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserSetting`. */
  userById: Maybe<User>;
  /** The `UserSetting` that was deleted by this mutation. */
  userSetting: Maybe<UserSetting>;
  /** An edge for our `UserSetting`. May be used by Relay 1. */
  userSettingEdge: Maybe<UserSettingsEdge>;
};


/** The output of our delete `UserSetting` mutation. */
export type DeleteUserSettingPayloadUserSettingEdgeArgs = {
  orderBy?: InputMaybe<Array<UserSettingsOrderBy>>;
};

/** All input for the `forgotPassword` mutation. */
export type ForgotPasswordInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  email: Scalars['String'];
};

/** The output of our `forgotPassword` mutation. */
export type ForgotPasswordPayload = {
  __typename?: 'ForgotPasswordPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};

export type Friend = Node & {
  __typename?: 'Friend';
  accepted: Maybe<Scalars['Date']>;
  blockedBy: Maybe<Scalars['UUID']>;
  id: Scalars['Int'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  sent: Scalars['Date'];
  status: FriendStatus;
  /** Reads a single `User` that is related to this `Friend`. */
  userByBlockedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId1: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId2: Maybe<User>;
  userId1: Scalars['UUID'];
  userId2: Scalars['UUID'];
};

/** A condition to be used against `Friend` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type FriendCondition = {
  /** Checks for equality with the object’s `accepted` field. */
  accepted: InputMaybe<Scalars['Date']>;
  /** Checks for equality with the object’s `blockedBy` field. */
  blockedBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `sent` field. */
  sent: InputMaybe<Scalars['Date']>;
  /** Checks for equality with the object’s `status` field. */
  status: InputMaybe<FriendStatus>;
  /** Checks for equality with the object’s `userId1` field. */
  userId1: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `userId2` field. */
  userId2: InputMaybe<Scalars['UUID']>;
};

/** An input for mutations affecting `Friend` */
export type FriendInput = {
  accepted: InputMaybe<Scalars['Date']>;
  blockedBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  sent: InputMaybe<Scalars['Date']>;
  status: InputMaybe<FriendStatus>;
  userId1: Scalars['UUID'];
  userId2: Scalars['UUID'];
};

/** Represents an update to a `Friend`. Fields that are set will be updated. */
export type FriendPatch = {
  accepted: InputMaybe<Scalars['Date']>;
  blockedBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  sent: InputMaybe<Scalars['Date']>;
  status: InputMaybe<FriendStatus>;
  userId1: InputMaybe<Scalars['UUID']>;
  userId2: InputMaybe<Scalars['UUID']>;
};

export enum FriendStatus {
  Accepted = 'ACCEPTED',
  Blocked = 'BLOCKED',
  Pending = 'PENDING'
}

/** A connection to a list of `Friend` values. */
export type FriendsConnection = {
  __typename?: 'FriendsConnection';
  /** A list of edges which contains the `Friend` and cursor to aid in pagination. */
  edges: Array<FriendsEdge>;
  /** A list of `Friend` objects. */
  nodes: Array<Maybe<Friend>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Friend` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Friend` edge in the connection. */
export type FriendsEdge = {
  __typename?: 'FriendsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Friend` at the end of the edge. */
  node: Maybe<Friend>;
};

/** Methods to use when ordering `Friend`. */
export enum FriendsOrderBy {
  AcceptedAsc = 'ACCEPTED_ASC',
  AcceptedDesc = 'ACCEPTED_DESC',
  BlockedByAsc = 'BLOCKED_BY_ASC',
  BlockedByDesc = 'BLOCKED_BY_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  SentAsc = 'SENT_ASC',
  SentDesc = 'SENT_DESC',
  StatusAsc = 'STATUS_ASC',
  StatusDesc = 'STATUS_DESC',
  UserId_1Asc = 'USER_ID_1_ASC',
  UserId_1Desc = 'USER_ID_1_DESC',
  UserId_2Asc = 'USER_ID_2_ASC',
  UserId_2Desc = 'USER_ID_2_DESC'
}

/** Item defines a product that can be rated */
export type Item = Node & {
  __typename?: 'Item';
  /** Reads and enables pagination through a set of `ActivityFeed`. */
  activityFeeds: ActivityFeedsConnection;
  averageRating: Maybe<Scalars['BigFloat']>;
  /** Reads a single `Brand` that is related to this `Item`. */
  brand: Maybe<Brand>;
  brandId: Scalars['Int'];
  /** Reads and enables pagination through a set of `CheckIn`. */
  checkIns: CheckInsConnection;
  checkInsPastMonth: Maybe<Scalars['Int']>;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  currentUserCheckIns: Maybe<Scalars['Int']>;
  description: Maybe<Scalars['String']>;
  flavor: Maybe<Scalars['String']>;
  id: Scalars['Int'];
  isTasted: Maybe<Scalars['Boolean']>;
  isVerified: Maybe<Scalars['Boolean']>;
  /** Reads and enables pagination through a set of `ItemEditSuggestion`. */
  itemEditSuggestions: ItemEditSuggestionsConnection;
  /** Reads a single `Company` that is related to this `Item`. */
  manufacturer: Maybe<Company>;
  manufacturerId: Scalars['Int'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  totalCheckIns: Maybe<Scalars['Int']>;
  /** Reads a single `Type` that is related to this `Item`. */
  type: Maybe<Type>;
  typeId: Scalars['Int'];
  uniqueCheckIns: Maybe<Scalars['Int']>;
  updatedAt: Scalars['Datetime'];
  updatedBy: Maybe<Scalars['UUID']>;
  /** Reads a single `User` that is related to this `Item`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Item`. */
  userByUpdatedBy: Maybe<User>;
};


/** Item defines a product that can be rated */
export type ItemActivityFeedsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ActivityFeedCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ActivityFeedsOrderBy>>;
};


/** Item defines a product that can be rated */
export type ItemCheckInsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};


/** Item defines a product that can be rated */
export type ItemItemEditSuggestionsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemEditSuggestionCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};

/** A condition to be used against `Item` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type ItemCondition = {
  /** Checks for equality with the object’s `brandId` field. */
  brandId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `createdBy` field. */
  createdBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `description` field. */
  description: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `flavor` field. */
  flavor: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `manufacturerId` field. */
  manufacturerId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `typeId` field. */
  typeId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `updatedBy` field. */
  updatedBy: InputMaybe<Scalars['UUID']>;
};

export type ItemEditSuggestion = Node & {
  __typename?: 'ItemEditSuggestion';
  accepted: Maybe<Scalars['Datetime']>;
  /** Reads a single `User` that is related to this `ItemEditSuggestion`. */
  author: Maybe<User>;
  authorId: Scalars['UUID'];
  /** Reads a single `Brand` that is related to this `ItemEditSuggestion`. */
  brand: Maybe<Brand>;
  brandId: Scalars['Int'];
  createdAt: Scalars['Datetime'];
  description: Maybe<Scalars['LongText']>;
  flavor: Maybe<Scalars['ShortText']>;
  id: Scalars['Int'];
  /** Reads a single `Item` that is related to this `ItemEditSuggestion`. */
  item: Maybe<Item>;
  itemId: Scalars['Int'];
  /** Reads a single `Company` that is related to this `ItemEditSuggestion`. */
  manufacturer: Maybe<Company>;
  manufacturerId: Maybe<Scalars['Int']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `Type` that is related to this `ItemEditSuggestion`. */
  type: Maybe<Type>;
  typeId: Scalars['Int'];
};

/**
 * A condition to be used against `ItemEditSuggestion` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type ItemEditSuggestionCondition = {
  /** Checks for equality with the object’s `accepted` field. */
  accepted: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `authorId` field. */
  authorId: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `brandId` field. */
  brandId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `description` field. */
  description: InputMaybe<Scalars['LongText']>;
  /** Checks for equality with the object’s `flavor` field. */
  flavor: InputMaybe<Scalars['ShortText']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `itemId` field. */
  itemId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `manufacturerId` field. */
  manufacturerId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `typeId` field. */
  typeId: InputMaybe<Scalars['Int']>;
};

/** An input for mutations affecting `ItemEditSuggestion` */
export type ItemEditSuggestionInput = {
  accepted: InputMaybe<Scalars['Datetime']>;
  authorId: Scalars['UUID'];
  brandId: Scalars['Int'];
  createdAt: InputMaybe<Scalars['Datetime']>;
  description: InputMaybe<Scalars['LongText']>;
  flavor: InputMaybe<Scalars['ShortText']>;
  id: InputMaybe<Scalars['Int']>;
  itemId: Scalars['Int'];
  manufacturerId: InputMaybe<Scalars['Int']>;
  typeId: Scalars['Int'];
};

/** Represents an update to a `ItemEditSuggestion`. Fields that are set will be updated. */
export type ItemEditSuggestionPatch = {
  accepted: InputMaybe<Scalars['Datetime']>;
  authorId: InputMaybe<Scalars['UUID']>;
  brandId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  description: InputMaybe<Scalars['LongText']>;
  flavor: InputMaybe<Scalars['ShortText']>;
  id: InputMaybe<Scalars['Int']>;
  itemId: InputMaybe<Scalars['Int']>;
  manufacturerId: InputMaybe<Scalars['Int']>;
  typeId: InputMaybe<Scalars['Int']>;
};

/** A connection to a list of `ItemEditSuggestion` values. */
export type ItemEditSuggestionsConnection = {
  __typename?: 'ItemEditSuggestionsConnection';
  /** A list of edges which contains the `ItemEditSuggestion` and cursor to aid in pagination. */
  edges: Array<ItemEditSuggestionsEdge>;
  /** A list of `ItemEditSuggestion` objects. */
  nodes: Array<Maybe<ItemEditSuggestion>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `ItemEditSuggestion` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `ItemEditSuggestion` edge in the connection. */
export type ItemEditSuggestionsEdge = {
  __typename?: 'ItemEditSuggestionsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `ItemEditSuggestion` at the end of the edge. */
  node: Maybe<ItemEditSuggestion>;
};

/** Methods to use when ordering `ItemEditSuggestion`. */
export enum ItemEditSuggestionsOrderBy {
  AcceptedAsc = 'ACCEPTED_ASC',
  AcceptedDesc = 'ACCEPTED_DESC',
  AuthorIdAsc = 'AUTHOR_ID_ASC',
  AuthorIdDesc = 'AUTHOR_ID_DESC',
  BrandIdAsc = 'BRAND_ID_ASC',
  BrandIdDesc = 'BRAND_ID_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  DescriptionAsc = 'DESCRIPTION_ASC',
  DescriptionDesc = 'DESCRIPTION_DESC',
  FlavorAsc = 'FLAVOR_ASC',
  FlavorDesc = 'FLAVOR_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  ItemIdAsc = 'ITEM_ID_ASC',
  ItemIdDesc = 'ITEM_ID_DESC',
  ManufacturerIdAsc = 'MANUFACTURER_ID_ASC',
  ManufacturerIdDesc = 'MANUFACTURER_ID_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  TypeIdAsc = 'TYPE_ID_ASC',
  TypeIdDesc = 'TYPE_ID_DESC'
}

/** An input for mutations affecting `Item` */
export type ItemInput = {
  brandId: Scalars['Int'];
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  description: InputMaybe<Scalars['String']>;
  flavor: InputMaybe<Scalars['String']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  manufacturerId: Scalars['Int'];
  typeId: Scalars['Int'];
  updatedAt: InputMaybe<Scalars['Datetime']>;
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** Represents an update to a `Item`. Fields that are set will be updated. */
export type ItemPatch = {
  brandId: InputMaybe<Scalars['Int']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  description: InputMaybe<Scalars['String']>;
  flavor: InputMaybe<Scalars['String']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  manufacturerId: InputMaybe<Scalars['Int']>;
  typeId: InputMaybe<Scalars['Int']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  updatedBy: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `Item` values. */
export type ItemsConnection = {
  __typename?: 'ItemsConnection';
  /** A list of edges which contains the `Item` and cursor to aid in pagination. */
  edges: Array<ItemsEdge>;
  /** A list of `Item` objects. */
  nodes: Array<Maybe<Item>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Item` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Item` edge in the connection. */
export type ItemsEdge = {
  __typename?: 'ItemsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Item` at the end of the edge. */
  node: Maybe<Item>;
};

/** Methods to use when ordering `Item`. */
export enum ItemsOrderBy {
  BrandIdAsc = 'BRAND_ID_ASC',
  BrandIdDesc = 'BRAND_ID_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  CreatedByAsc = 'CREATED_BY_ASC',
  CreatedByDesc = 'CREATED_BY_DESC',
  DescriptionAsc = 'DESCRIPTION_ASC',
  DescriptionDesc = 'DESCRIPTION_DESC',
  FlavorAsc = 'FLAVOR_ASC',
  FlavorDesc = 'FLAVOR_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsVerifiedAsc = 'IS_VERIFIED_ASC',
  IsVerifiedDesc = 'IS_VERIFIED_DESC',
  ManufacturerIdAsc = 'MANUFACTURER_ID_ASC',
  ManufacturerIdDesc = 'MANUFACTURER_ID_DESC',
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

/** All input for the `likeCheckIn` mutation. */
export type LikeCheckInInput = {
  checkInId: InputMaybe<Scalars['Int']>;
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our `likeCheckIn` mutation. */
export type LikeCheckInPayload = {
  __typename?: 'LikeCheckInPayload';
  /** Reads a single `User` that is related to this `CheckIn`. */
  author: Maybe<User>;
  checkIn: Maybe<CheckIn>;
  /** An edge for our `CheckIn`. May be used by Relay 1. */
  checkInEdge: Maybe<CheckInsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Item` that is related to this `CheckIn`. */
  item: Maybe<Item>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our `likeCheckIn` mutation. */
export type LikeCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the `makeEmailPrimary` mutation. */
export type MakeEmailPrimaryInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  emailId: Scalars['UUID'];
};

/** The output of our `makeEmailPrimary` mutation. */
export type MakeEmailPrimaryPayload = {
  __typename?: 'MakeEmailPrimaryPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserEmail`. */
  user: Maybe<User>;
  userEmail: Maybe<UserEmail>;
  /** An edge for our `UserEmail`. May be used by Relay 1. */
  userEmailEdge: Maybe<UserEmailsEdge>;
};


/** The output of our `makeEmailPrimary` mutation. */
export type MakeEmailPrimaryPayloadUserEmailEdgeArgs = {
  orderBy?: InputMaybe<Array<UserEmailsOrderBy>>;
};

/** The root mutation type which contains root level fields which mutate data. */
export type Mutation = {
  __typename?: 'Mutation';
  acceptFriendRequest: Maybe<AcceptFriendRequestPayload>;
  /** Enter your old password and a new password to change your password. */
  changePassword: Maybe<ChangePasswordPayload>;
  /** If you're certain you want to delete your account, use `requestAccountDeletion` to request an account deletion token, and then supply the token through this mutation to complete account deletion. */
  confirmAccountDeletion: Maybe<ConfirmAccountDeletionPayload>;
  /** Creates a single `Brand`. */
  createBrand: Maybe<CreateBrandPayload>;
  /** Creates a single `Category`. */
  createCategory: Maybe<CreateCategoryPayload>;
  /** Creates a single `CheckIn`. */
  createCheckIn: Maybe<CreateCheckInPayload>;
  /** Creates a single `CheckInComment`. */
  createCheckInComment: Maybe<CreateCheckInCommentPayload>;
  /** Creates a single `CheckInFriend`. */
  createCheckInFriend: Maybe<CreateCheckInFriendPayload>;
  /** Creates a single `CheckInLike`. */
  createCheckInLike: Maybe<CreateCheckInLikePayload>;
  /** Creates a single `CheckInTag`. */
  createCheckInTag: Maybe<CreateCheckInTagPayload>;
  /** Creates a single `Company`. */
  createCompany: Maybe<CreateCompanyPayload>;
  /** Creates a single `CompanyLike`. */
  createCompanyLike: Maybe<CreateCompanyLikePayload>;
  /** Creates a single `Friend`. */
  createFriend: Maybe<CreateFriendPayload>;
  createFriendRequest: Maybe<CreateFriendRequestPayload>;
  /** Creates a single `Item`. */
  createItem: Maybe<CreateItemPayload>;
  /** Creates a single `ItemEditSuggestion`. */
  createItemEditSuggestion: Maybe<CreateItemEditSuggestionPayload>;
  /** Creates a single `PublicCheckIn`. */
  createPublicCheckIn: Maybe<CreatePublicCheckInPayload>;
  /** Creates a single `Tag`. */
  createTag: Maybe<CreateTagPayload>;
  /** Creates a single `Type`. */
  createType: Maybe<CreateTypePayload>;
  /** Creates a single `User`. */
  createUser: Maybe<CreateUserPayload>;
  /** Creates a single `UserAuthentication`. */
  createUserAuthentication: Maybe<CreateUserAuthenticationPayload>;
  /** Creates a single `UserEmail`. */
  createUserEmail: Maybe<CreateUserEmailPayload>;
  /** Creates a single `UserSetting`. */
  createUserSetting: Maybe<CreateUserSettingPayload>;
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
  /** Deletes a single `CheckInComment` using a unique key. */
  deleteCheckInComment: Maybe<DeleteCheckInCommentPayload>;
  /** Deletes a single `CheckInComment` using its globally unique id. */
  deleteCheckInCommentByNodeId: Maybe<DeleteCheckInCommentPayload>;
  /** Deletes a single `CheckInLike` using a unique key. */
  deleteCheckInLike: Maybe<DeleteCheckInLikePayload>;
  /** Deletes a single `CheckInLike` using its globally unique id. */
  deleteCheckInLikeByNodeId: Maybe<DeleteCheckInLikePayload>;
  /** Deletes a single `CheckInTag` using a unique key. */
  deleteCheckInTag: Maybe<DeleteCheckInTagPayload>;
  /** Deletes a single `CheckInTag` using its globally unique id. */
  deleteCheckInTagByNodeId: Maybe<DeleteCheckInTagPayload>;
  /** Deletes a single `Company` using a unique key. */
  deleteCompany: Maybe<DeleteCompanyPayload>;
  /** Deletes a single `Company` using a unique key. */
  deleteCompanyByName: Maybe<DeleteCompanyPayload>;
  /** Deletes a single `Company` using its globally unique id. */
  deleteCompanyByNodeId: Maybe<DeleteCompanyPayload>;
  /** Deletes a single `CompanyLike` using a unique key. */
  deleteCompanyLike: Maybe<DeleteCompanyLikePayload>;
  /** Deletes a single `CompanyLike` using its globally unique id. */
  deleteCompanyLikeByNodeId: Maybe<DeleteCompanyLikePayload>;
  /** Deletes a single `Friend` using a unique key. */
  deleteFriend: Maybe<DeleteFriendPayload>;
  /** Deletes a single `Friend` using its globally unique id. */
  deleteFriendByNodeId: Maybe<DeleteFriendPayload>;
  /** Deletes a single `Item` using a unique key. */
  deleteItem: Maybe<DeleteItemPayload>;
  /** Deletes a single `Item` using a unique key. */
  deleteItemByBrandIdAndFlavor: Maybe<DeleteItemPayload>;
  /** Deletes a single `Item` using its globally unique id. */
  deleteItemByNodeId: Maybe<DeleteItemPayload>;
  /** Deletes a single `ItemEditSuggestion` using a unique key. */
  deleteItemEditSuggestion: Maybe<DeleteItemEditSuggestionPayload>;
  /** Deletes a single `ItemEditSuggestion` using its globally unique id. */
  deleteItemEditSuggestionByNodeId: Maybe<DeleteItemEditSuggestionPayload>;
  /** Deletes a single `Tag` using a unique key. */
  deleteTag: Maybe<DeleteTagPayload>;
  /** Deletes a single `Tag` using a unique key. */
  deleteTagByName: Maybe<DeleteTagPayload>;
  /** Deletes a single `Tag` using its globally unique id. */
  deleteTagByNodeId: Maybe<DeleteTagPayload>;
  /** Deletes a single `Type` using a unique key. */
  deleteType: Maybe<DeleteTypePayload>;
  /** Deletes a single `Type` using a unique key. */
  deleteTypeByNameAndCategory: Maybe<DeleteTypePayload>;
  /** Deletes a single `Type` using its globally unique id. */
  deleteTypeByNodeId: Maybe<DeleteTypePayload>;
  /** Deletes a single `User` using a unique key. */
  deleteUser: Maybe<DeleteUserPayload>;
  /** Deletes a single `UserAuthentication` using a unique key. */
  deleteUserAuthentication: Maybe<DeleteUserAuthenticationPayload>;
  /** Deletes a single `UserAuthentication` using its globally unique id. */
  deleteUserAuthenticationByNodeId: Maybe<DeleteUserAuthenticationPayload>;
  /** Deletes a single `User` using its globally unique id. */
  deleteUserByNodeId: Maybe<DeleteUserPayload>;
  /** Deletes a single `User` using a unique key. */
  deleteUserByUsername: Maybe<DeleteUserPayload>;
  /** Deletes a single `UserEmail` using a unique key. */
  deleteUserEmail: Maybe<DeleteUserEmailPayload>;
  /** Deletes a single `UserEmail` using its globally unique id. */
  deleteUserEmailByNodeId: Maybe<DeleteUserEmailPayload>;
  /** Deletes a single `UserSetting` using a unique key. */
  deleteUserSetting: Maybe<DeleteUserSettingPayload>;
  /** Deletes a single `UserSetting` using its globally unique id. */
  deleteUserSettingByNodeId: Maybe<DeleteUserSettingPayload>;
  /** If you've forgotten your password, give us one of your email addresses and we'll send you a reset token. Note this only works if you have added an email address! */
  forgotPassword: Maybe<ForgotPasswordPayload>;
  likeCheckIn: Maybe<LikeCheckInPayload>;
  /** Your primary email is where we'll notify of account events; other emails may be used for discovery or login. Use this when you're changing your email address. */
  makeEmailPrimary: Maybe<MakeEmailPrimaryPayload>;
  /** Begin the account deletion flow by requesting the confirmation email */
  requestAccountDeletion: Maybe<RequestAccountDeletionPayload>;
  /** If you didn't receive the verification code for this email, we can resend it. We silently cap the rate of resends on the backend, so calls to this function may not result in another email being sent if it has been called recently. */
  resendEmailVerificationCode: Maybe<ResendEmailVerificationCodePayload>;
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
  /** Updates a single `CheckInComment` using a unique key and a patch. */
  updateCheckInComment: Maybe<UpdateCheckInCommentPayload>;
  /** Updates a single `CheckInComment` using its globally unique id and a patch. */
  updateCheckInCommentByNodeId: Maybe<UpdateCheckInCommentPayload>;
  /** Updates a single `CheckInLike` using a unique key and a patch. */
  updateCheckInLike: Maybe<UpdateCheckInLikePayload>;
  /** Updates a single `CheckInLike` using its globally unique id and a patch. */
  updateCheckInLikeByNodeId: Maybe<UpdateCheckInLikePayload>;
  /** Updates a single `CheckInTag` using a unique key and a patch. */
  updateCheckInTag: Maybe<UpdateCheckInTagPayload>;
  /** Updates a single `CheckInTag` using its globally unique id and a patch. */
  updateCheckInTagByNodeId: Maybe<UpdateCheckInTagPayload>;
  /** Updates a single `Company` using a unique key and a patch. */
  updateCompany: Maybe<UpdateCompanyPayload>;
  /** Updates a single `Company` using a unique key and a patch. */
  updateCompanyByName: Maybe<UpdateCompanyPayload>;
  /** Updates a single `Company` using its globally unique id and a patch. */
  updateCompanyByNodeId: Maybe<UpdateCompanyPayload>;
  /** Updates a single `CompanyLike` using a unique key and a patch. */
  updateCompanyLike: Maybe<UpdateCompanyLikePayload>;
  /** Updates a single `CompanyLike` using its globally unique id and a patch. */
  updateCompanyLikeByNodeId: Maybe<UpdateCompanyLikePayload>;
  /** Updates a single `Friend` using a unique key and a patch. */
  updateFriend: Maybe<UpdateFriendPayload>;
  /** Updates a single `Friend` using its globally unique id and a patch. */
  updateFriendByNodeId: Maybe<UpdateFriendPayload>;
  /** Updates a single `Item` using a unique key and a patch. */
  updateItem: Maybe<UpdateItemPayload>;
  /** Updates a single `Item` using a unique key and a patch. */
  updateItemByBrandIdAndFlavor: Maybe<UpdateItemPayload>;
  /** Updates a single `Item` using its globally unique id and a patch. */
  updateItemByNodeId: Maybe<UpdateItemPayload>;
  /** Updates a single `ItemEditSuggestion` using a unique key and a patch. */
  updateItemEditSuggestion: Maybe<UpdateItemEditSuggestionPayload>;
  /** Updates a single `ItemEditSuggestion` using its globally unique id and a patch. */
  updateItemEditSuggestionByNodeId: Maybe<UpdateItemEditSuggestionPayload>;
  /** Updates a single `Tag` using a unique key and a patch. */
  updateTag: Maybe<UpdateTagPayload>;
  /** Updates a single `Tag` using a unique key and a patch. */
  updateTagByName: Maybe<UpdateTagPayload>;
  /** Updates a single `Tag` using its globally unique id and a patch. */
  updateTagByNodeId: Maybe<UpdateTagPayload>;
  /** Updates a single `Type` using a unique key and a patch. */
  updateType: Maybe<UpdateTypePayload>;
  /** Updates a single `Type` using a unique key and a patch. */
  updateTypeByNameAndCategory: Maybe<UpdateTypePayload>;
  /** Updates a single `Type` using its globally unique id and a patch. */
  updateTypeByNodeId: Maybe<UpdateTypePayload>;
  /** Updates a single `User` using a unique key and a patch. */
  updateUser: Maybe<UpdateUserPayload>;
  /** Updates a single `UserAuthentication` using a unique key and a patch. */
  updateUserAuthentication: Maybe<UpdateUserAuthenticationPayload>;
  /** Updates a single `UserAuthentication` using its globally unique id and a patch. */
  updateUserAuthenticationByNodeId: Maybe<UpdateUserAuthenticationPayload>;
  /** Updates a single `User` using its globally unique id and a patch. */
  updateUserByNodeId: Maybe<UpdateUserPayload>;
  /** Updates a single `User` using a unique key and a patch. */
  updateUserByUsername: Maybe<UpdateUserPayload>;
  /** Updates a single `UserEmail` using a unique key and a patch. */
  updateUserEmail: Maybe<UpdateUserEmailPayload>;
  /** Updates a single `UserEmail` using its globally unique id and a patch. */
  updateUserEmailByNodeId: Maybe<UpdateUserEmailPayload>;
  /** Updates a single `UserSetting` using a unique key and a patch. */
  updateUserSetting: Maybe<UpdateUserSettingPayload>;
  /** Updates a single `UserSetting` using its globally unique id and a patch. */
  updateUserSettingByNodeId: Maybe<UpdateUserSettingPayload>;
  /** Once you have received a verification token for your email, you may call this mutation with that token to make your email verified. */
  verifyEmail: Maybe<VerifyEmailPayload>;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationAcceptFriendRequestArgs = {
  input: AcceptFriendRequestInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationChangePasswordArgs = {
  input: ChangePasswordInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationConfirmAccountDeletionArgs = {
  input: ConfirmAccountDeletionInput;
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
export type MutationCreateCheckInCommentArgs = {
  input: CreateCheckInCommentInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCheckInFriendArgs = {
  input: CreateCheckInFriendInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCheckInLikeArgs = {
  input: CreateCheckInLikeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCheckInTagArgs = {
  input: CreateCheckInTagInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCompanyArgs = {
  input: CreateCompanyInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateCompanyLikeArgs = {
  input: CreateCompanyLikeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateFriendArgs = {
  input: CreateFriendInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateFriendRequestArgs = {
  input: CreateFriendRequestInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateItemArgs = {
  input: CreateItemInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateItemEditSuggestionArgs = {
  input: CreateItemEditSuggestionInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreatePublicCheckInArgs = {
  input: CreatePublicCheckInInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateTagArgs = {
  input: CreateTagInput;
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
export type MutationCreateUserAuthenticationArgs = {
  input: CreateUserAuthenticationInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateUserEmailArgs = {
  input: CreateUserEmailInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationCreateUserSettingArgs = {
  input: CreateUserSettingInput;
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
export type MutationDeleteCheckInCommentArgs = {
  input: DeleteCheckInCommentInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInCommentByNodeIdArgs = {
  input: DeleteCheckInCommentByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInLikeArgs = {
  input: DeleteCheckInLikeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInLikeByNodeIdArgs = {
  input: DeleteCheckInLikeByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInTagArgs = {
  input: DeleteCheckInTagInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCheckInTagByNodeIdArgs = {
  input: DeleteCheckInTagByNodeIdInput;
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
export type MutationDeleteCompanyLikeArgs = {
  input: DeleteCompanyLikeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteCompanyLikeByNodeIdArgs = {
  input: DeleteCompanyLikeByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteFriendArgs = {
  input: DeleteFriendInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteFriendByNodeIdArgs = {
  input: DeleteFriendByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteItemArgs = {
  input: DeleteItemInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteItemByBrandIdAndFlavorArgs = {
  input: DeleteItemByBrandIdAndFlavorInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteItemByNodeIdArgs = {
  input: DeleteItemByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteItemEditSuggestionArgs = {
  input: DeleteItemEditSuggestionInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteItemEditSuggestionByNodeIdArgs = {
  input: DeleteItemEditSuggestionByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteTagArgs = {
  input: DeleteTagInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteTagByNameArgs = {
  input: DeleteTagByNameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteTagByNodeIdArgs = {
  input: DeleteTagByNodeIdInput;
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
export type MutationDeleteUserAuthenticationArgs = {
  input: DeleteUserAuthenticationInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserAuthenticationByNodeIdArgs = {
  input: DeleteUserAuthenticationByNodeIdInput;
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
export type MutationDeleteUserEmailArgs = {
  input: DeleteUserEmailInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserEmailByNodeIdArgs = {
  input: DeleteUserEmailByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserSettingArgs = {
  input: DeleteUserSettingInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationDeleteUserSettingByNodeIdArgs = {
  input: DeleteUserSettingByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationForgotPasswordArgs = {
  input: ForgotPasswordInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationLikeCheckInArgs = {
  input: LikeCheckInInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationMakeEmailPrimaryArgs = {
  input: MakeEmailPrimaryInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationRequestAccountDeletionArgs = {
  input: RequestAccountDeletionInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationResendEmailVerificationCodeArgs = {
  input: ResendEmailVerificationCodeInput;
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
export type MutationUpdateCheckInCommentArgs = {
  input: UpdateCheckInCommentInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInCommentByNodeIdArgs = {
  input: UpdateCheckInCommentByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInLikeArgs = {
  input: UpdateCheckInLikeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInLikeByNodeIdArgs = {
  input: UpdateCheckInLikeByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInTagArgs = {
  input: UpdateCheckInTagInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCheckInTagByNodeIdArgs = {
  input: UpdateCheckInTagByNodeIdInput;
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
export type MutationUpdateCompanyLikeArgs = {
  input: UpdateCompanyLikeInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateCompanyLikeByNodeIdArgs = {
  input: UpdateCompanyLikeByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateFriendArgs = {
  input: UpdateFriendInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateFriendByNodeIdArgs = {
  input: UpdateFriendByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateItemArgs = {
  input: UpdateItemInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateItemByBrandIdAndFlavorArgs = {
  input: UpdateItemByBrandIdAndFlavorInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateItemByNodeIdArgs = {
  input: UpdateItemByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateItemEditSuggestionArgs = {
  input: UpdateItemEditSuggestionInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateItemEditSuggestionByNodeIdArgs = {
  input: UpdateItemEditSuggestionByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateTagArgs = {
  input: UpdateTagInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateTagByNameArgs = {
  input: UpdateTagByNameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateTagByNodeIdArgs = {
  input: UpdateTagByNodeIdInput;
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
export type MutationUpdateUserAuthenticationArgs = {
  input: UpdateUserAuthenticationInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserAuthenticationByNodeIdArgs = {
  input: UpdateUserAuthenticationByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserByNodeIdArgs = {
  input: UpdateUserByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserByUsernameArgs = {
  input: UpdateUserByUsernameInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserEmailArgs = {
  input: UpdateUserEmailInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserEmailByNodeIdArgs = {
  input: UpdateUserEmailByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserSettingArgs = {
  input: UpdateUserSettingInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationUpdateUserSettingByNodeIdArgs = {
  input: UpdateUserSettingByNodeIdInput;
};


/** The root mutation type which contains root level fields which mutate data. */
export type MutationVerifyEmailArgs = {
  input: VerifyEmailInput;
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

export type PublicCheckIn = {
  __typename?: 'PublicCheckIn';
  authorId: Maybe<Scalars['UUID']>;
  checkInDate: Maybe<Scalars['Date']>;
  createdAt: Maybe<Scalars['Datetime']>;
  id: Maybe<Scalars['Int']>;
  isPublic: Maybe<Scalars['Boolean']>;
  itemId: Maybe<Scalars['Int']>;
  location: Maybe<Scalars['UUID']>;
  rating: Maybe<Scalars['Int']>;
  review: Maybe<Scalars['String']>;
};

/**
 * A condition to be used against `PublicCheckIn` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type PublicCheckInCondition = {
  /** Checks for equality with the object’s `authorId` field. */
  authorId: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `checkInDate` field. */
  checkInDate: InputMaybe<Scalars['Date']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `isPublic` field. */
  isPublic: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `itemId` field. */
  itemId: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `location` field. */
  location: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `rating` field. */
  rating: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `review` field. */
  review: InputMaybe<Scalars['String']>;
};

/** An input for mutations affecting `PublicCheckIn` */
export type PublicCheckInInput = {
  authorId: InputMaybe<Scalars['UUID']>;
  checkInDate: InputMaybe<Scalars['Date']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['Int']>;
  isPublic: InputMaybe<Scalars['Boolean']>;
  itemId: InputMaybe<Scalars['Int']>;
  location: InputMaybe<Scalars['UUID']>;
  rating: InputMaybe<Scalars['Int']>;
  review: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `PublicCheckIn` values. */
export type PublicCheckInsConnection = {
  __typename?: 'PublicCheckInsConnection';
  /** A list of edges which contains the `PublicCheckIn` and cursor to aid in pagination. */
  edges: Array<PublicCheckInsEdge>;
  /** A list of `PublicCheckIn` objects. */
  nodes: Array<Maybe<PublicCheckIn>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `PublicCheckIn` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `PublicCheckIn` edge in the connection. */
export type PublicCheckInsEdge = {
  __typename?: 'PublicCheckInsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `PublicCheckIn` at the end of the edge. */
  node: Maybe<PublicCheckIn>;
};

/** Methods to use when ordering `PublicCheckIn`. */
export enum PublicCheckInsOrderBy {
  AuthorIdAsc = 'AUTHOR_ID_ASC',
  AuthorIdDesc = 'AUTHOR_ID_DESC',
  CheckInDateAsc = 'CHECK_IN_DATE_ASC',
  CheckInDateDesc = 'CHECK_IN_DATE_DESC',
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsPublicAsc = 'IS_PUBLIC_ASC',
  IsPublicDesc = 'IS_PUBLIC_DESC',
  ItemIdAsc = 'ITEM_ID_ASC',
  ItemIdDesc = 'ITEM_ID_DESC',
  LocationAsc = 'LOCATION_ASC',
  LocationDesc = 'LOCATION_DESC',
  Natural = 'NATURAL',
  RatingAsc = 'RATING_ASC',
  RatingDesc = 'RATING_DESC',
  ReviewAsc = 'REVIEW_ASC',
  ReviewDesc = 'REVIEW_DESC'
}

export type PublicUser = {
  __typename?: 'PublicUser';
  avatarUrl: Maybe<Scalars['String']>;
  country: Maybe<Scalars['String']>;
  createdAt: Maybe<Scalars['Datetime']>;
  firstName: Maybe<Scalars['String']>;
  id: Maybe<Scalars['UUID']>;
  isAdmin: Maybe<Scalars['Boolean']>;
  isVerified: Maybe<Scalars['Boolean']>;
  lastName: Maybe<Scalars['String']>;
  location: Maybe<Scalars['String']>;
  status: Maybe<FriendStatus>;
  updatedAt: Maybe<Scalars['Datetime']>;
  username: Maybe<Scalars['String']>;
};

/**
 * A condition to be used against `PublicUser` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type PublicUserCondition = {
  /** Checks for equality with the object’s `avatarUrl` field. */
  avatarUrl: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `country` field. */
  country: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `firstName` field. */
  firstName: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `isAdmin` field. */
  isAdmin: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `lastName` field. */
  lastName: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `location` field. */
  location: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `status` field. */
  status: InputMaybe<FriendStatus>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `username` field. */
  username: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `PublicUser` values. */
export type PublicUsersConnection = {
  __typename?: 'PublicUsersConnection';
  /** A list of edges which contains the `PublicUser` and cursor to aid in pagination. */
  edges: Array<PublicUsersEdge>;
  /** A list of `PublicUser` objects. */
  nodes: Array<Maybe<PublicUser>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `PublicUser` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `PublicUser` edge in the connection. */
export type PublicUsersEdge = {
  __typename?: 'PublicUsersEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `PublicUser` at the end of the edge. */
  node: Maybe<PublicUser>;
};

/** Methods to use when ordering `PublicUser`. */
export enum PublicUsersOrderBy {
  AvatarUrlAsc = 'AVATAR_URL_ASC',
  AvatarUrlDesc = 'AVATAR_URL_DESC',
  CountryAsc = 'COUNTRY_ASC',
  CountryDesc = 'COUNTRY_DESC',
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
  LocationAsc = 'LOCATION_ASC',
  LocationDesc = 'LOCATION_DESC',
  Natural = 'NATURAL',
  StatusAsc = 'STATUS_ASC',
  StatusDesc = 'STATUS_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UsernameAsc = 'USERNAME_ASC',
  UsernameDesc = 'USERNAME_DESC'
}

/** The root query type which gives access points into the data universe. */
export type Query = Node & {
  __typename?: 'Query';
  /** Reads and enables pagination through a set of `ActivityFeed`. */
  activityFeeds: Maybe<ActivityFeedsConnection>;
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
  checkInComment: Maybe<CheckInComment>;
  /** Reads a single `CheckInComment` using its globally unique `ID`. */
  checkInCommentByNodeId: Maybe<CheckInComment>;
  /** Reads and enables pagination through a set of `CheckInComment`. */
  checkInComments: Maybe<CheckInCommentsConnection>;
  /** Reads and enables pagination through a set of `CheckInFriend`. */
  checkInFriends: Maybe<CheckInFriendsConnection>;
  checkInLike: Maybe<CheckInLike>;
  /** Reads a single `CheckInLike` using its globally unique `ID`. */
  checkInLikeByNodeId: Maybe<CheckInLike>;
  /** Reads and enables pagination through a set of `CheckInLike`. */
  checkInLikes: Maybe<CheckInLikesConnection>;
  checkInTag: Maybe<CheckInTag>;
  /** Reads a single `CheckInTag` using its globally unique `ID`. */
  checkInTagByNodeId: Maybe<CheckInTag>;
  /** Reads and enables pagination through a set of `CheckInTag`. */
  checkInTags: Maybe<CheckInTagsConnection>;
  /** Reads and enables pagination through a set of `CheckIn`. */
  checkIns: Maybe<CheckInsConnection>;
  /** Reads and enables pagination through a set of `Company`. */
  companies: Maybe<CompaniesConnection>;
  company: Maybe<Company>;
  companyByName: Maybe<Company>;
  /** Reads a single `Company` using its globally unique `ID`. */
  companyByNodeId: Maybe<Company>;
  companyLike: Maybe<CompanyLike>;
  /** Reads a single `CompanyLike` using its globally unique `ID`. */
  companyLikeByNodeId: Maybe<CompanyLike>;
  /** Reads and enables pagination through a set of `CompanyLike`. */
  companyLikes: Maybe<CompanyLikesConnection>;
  /** The currently logged in user (or null if not logged in). */
  currentUser: Maybe<User>;
  /** Reads and enables pagination through a set of `CurrentUserFriend`. */
  currentUserFriends: Maybe<CurrentUserFriendsConnection>;
  currentUserIsPrivileged: Maybe<Scalars['Boolean']>;
  friend: Maybe<Friend>;
  /** Reads a single `Friend` using its globally unique `ID`. */
  friendByNodeId: Maybe<Friend>;
  /** Reads and enables pagination through a set of `Friend`. */
  friends: Maybe<FriendsConnection>;
  item: Maybe<Item>;
  itemByBrandIdAndFlavor: Maybe<Item>;
  /** Reads a single `Item` using its globally unique `ID`. */
  itemByNodeId: Maybe<Item>;
  itemEditSuggestion: Maybe<ItemEditSuggestion>;
  /** Reads a single `ItemEditSuggestion` using its globally unique `ID`. */
  itemEditSuggestionByNodeId: Maybe<ItemEditSuggestion>;
  /** Reads and enables pagination through a set of `ItemEditSuggestion`. */
  itemEditSuggestions: Maybe<ItemEditSuggestionsConnection>;
  /** Reads and enables pagination through a set of `Item`. */
  items: Maybe<ItemsConnection>;
  /** Fetches an object given its globally unique `ID`. */
  node: Maybe<Node>;
  /** The root query type must be a `Node` to work well with Relay 1 mutations. This just resolves to `query`. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `PublicCheckIn`. */
  publicCheckIns: Maybe<PublicCheckInsConnection>;
  /** Reads and enables pagination through a set of `PublicUser`. */
  publicUsers: Maybe<PublicUsersConnection>;
  /**
   * Exposes the root query type nested one level down. This is helpful for Relay 1
   * which can only query top level fields if they are in a particular form.
   */
  query: Query;
  /** Reads and enables pagination through a set of `Item`. */
  searchItems: Maybe<ItemsConnection>;
  /** Reads and enables pagination through a set of `User`. */
  searchUsers: Maybe<UsersConnection>;
  tag: Maybe<Tag>;
  tagByName: Maybe<Tag>;
  /** Reads a single `Tag` using its globally unique `ID`. */
  tagByNodeId: Maybe<Tag>;
  /** Reads and enables pagination through a set of `Tag`. */
  tags: Maybe<TagsConnection>;
  type: Maybe<Type>;
  typeByNameAndCategory: Maybe<Type>;
  /** Reads a single `Type` using its globally unique `ID`. */
  typeByNodeId: Maybe<Type>;
  /** Reads and enables pagination through a set of `Type`. */
  types: Maybe<TypesConnection>;
  user: Maybe<User>;
  userAuthentication: Maybe<UserAuthentication>;
  /** Reads a single `UserAuthentication` using its globally unique `ID`. */
  userAuthenticationByNodeId: Maybe<UserAuthentication>;
  /** Reads a single `User` using its globally unique `ID`. */
  userByNodeId: Maybe<User>;
  userByUsername: Maybe<User>;
  userEmail: Maybe<UserEmail>;
  /** Reads a single `UserEmail` using its globally unique `ID`. */
  userEmailByNodeId: Maybe<UserEmail>;
  userSetting: Maybe<UserSetting>;
  /** Reads a single `UserSetting` using its globally unique `ID`. */
  userSettingByNodeId: Maybe<UserSetting>;
  /** Reads and enables pagination through a set of `UserSetting`. */
  userSettings: Maybe<UserSettingsConnection>;
};


/** The root query type which gives access points into the data universe. */
export type QueryActivityFeedsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ActivityFeedCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ActivityFeedsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryBrandByCompanyIdAndNameArgs = {
  companyId: Scalars['Int'];
  name: Scalars['ShortText'];
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
export type QueryCheckInCommentArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInCommentByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInCommentsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCommentCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInCommentsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInFriendsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInFriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInFriendsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInLikeArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInLikeByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInLikesArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInLikeCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInLikesOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInTagArgs = {
  checkInId: Scalars['Int'];
  tagId: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInTagByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCheckInTagsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInTagCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInTagsOrderBy>>;
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
  name: Scalars['String'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyLikeArgs = {
  id: Scalars['Int'];
  likedBy: Scalars['UUID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyLikeByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryCompanyLikesArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CompanyLikeCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompanyLikesOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryCurrentUserFriendsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CurrentUserFriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CurrentUserFriendsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryFriendArgs = {
  userId1: Scalars['UUID'];
  userId2: Scalars['UUID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryFriendByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryFriendsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<FriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryItemArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryItemByBrandIdAndFlavorArgs = {
  brandId: Scalars['Int'];
  flavor: Scalars['String'];
};


/** The root query type which gives access points into the data universe. */
export type QueryItemByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryItemEditSuggestionArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryItemEditSuggestionByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryItemEditSuggestionsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemEditSuggestionCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryItemsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryNodeArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryPublicCheckInsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<PublicCheckInCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<PublicCheckInsOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QueryPublicUsersArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<PublicUserCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<PublicUsersOrderBy>>;
};


/** The root query type which gives access points into the data universe. */
export type QuerySearchItemsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  search: InputMaybe<Scalars['String']>;
};


/** The root query type which gives access points into the data universe. */
export type QuerySearchUsersArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  search: InputMaybe<Scalars['String']>;
};


/** The root query type which gives access points into the data universe. */
export type QueryTagArgs = {
  id: Scalars['Int'];
};


/** The root query type which gives access points into the data universe. */
export type QueryTagByNameArgs = {
  name: Scalars['String'];
};


/** The root query type which gives access points into the data universe. */
export type QueryTagByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryTagsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<TagCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<TagsOrderBy>>;
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
export type QueryUserAuthenticationArgs = {
  id: Scalars['UUID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserAuthenticationByNodeIdArgs = {
  nodeId: Scalars['ID'];
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
export type QueryUserEmailArgs = {
  id: Scalars['UUID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserEmailByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserSettingArgs = {
  id: Scalars['UUID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserSettingByNodeIdArgs = {
  nodeId: Scalars['ID'];
};


/** The root query type which gives access points into the data universe. */
export type QueryUserSettingsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<UserSettingCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<UserSettingsOrderBy>>;
};

/** All input for the `requestAccountDeletion` mutation. */
export type RequestAccountDeletionInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
};

/** The output of our `requestAccountDeletion` mutation. */
export type RequestAccountDeletionPayload = {
  __typename?: 'RequestAccountDeletionPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  success: Maybe<Scalars['Boolean']>;
};

/** All input for the `resendEmailVerificationCode` mutation. */
export type ResendEmailVerificationCodeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  emailId: Scalars['UUID'];
};

/** The output of our `resendEmailVerificationCode` mutation. */
export type ResendEmailVerificationCodePayload = {
  __typename?: 'ResendEmailVerificationCodePayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  success: Maybe<Scalars['Boolean']>;
};

/** Tag for an item or check-in */
export type Tag = Node & {
  __typename?: 'Tag';
  /** Reads and enables pagination through a set of `CheckInTag`. */
  checkInTags: CheckInTagsConnection;
  createdAt: Scalars['Datetime'];
  createdBy: Maybe<Scalars['UUID']>;
  id: Scalars['Int'];
  isVerified: Scalars['Boolean'];
  name: Maybe<Scalars['String']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `User` that is related to this `Tag`. */
  userByCreatedBy: Maybe<User>;
};


/** Tag for an item or check-in */
export type TagCheckInTagsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInTagCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInTagsOrderBy>>;
};

/** A condition to be used against `Tag` object types. All fields are tested for equality and combined with a logical ‘and.’ */
export type TagCondition = {
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `createdBy` field. */
  createdBy: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['Int']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `name` field. */
  name: InputMaybe<Scalars['String']>;
};

/** An input for mutations affecting `Tag` */
export type TagInput = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['String']>;
};

/** Represents an update to a `Tag`. Fields that are set will be updated. */
export type TagPatch = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  createdBy: InputMaybe<Scalars['UUID']>;
  id: InputMaybe<Scalars['Int']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  name: InputMaybe<Scalars['String']>;
};

/** A connection to a list of `Tag` values. */
export type TagsConnection = {
  __typename?: 'TagsConnection';
  /** A list of edges which contains the `Tag` and cursor to aid in pagination. */
  edges: Array<TagsEdge>;
  /** A list of `Tag` objects. */
  nodes: Array<Maybe<Tag>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `Tag` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `Tag` edge in the connection. */
export type TagsEdge = {
  __typename?: 'TagsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `Tag` at the end of the edge. */
  node: Maybe<Tag>;
};

/** Methods to use when ordering `Tag`. */
export enum TagsOrderBy {
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

/** Type item that is part of a category */
export type Type = Node & {
  __typename?: 'Type';
  category: Scalars['String'];
  /** Reads a single `Category` that is related to this `Type`. */
  categoryByCategory: Maybe<Category>;
  id: Scalars['Int'];
  /** Reads and enables pagination through a set of `ItemEditSuggestion`. */
  itemEditSuggestions: ItemEditSuggestionsConnection;
  /** Reads and enables pagination through a set of `Item`. */
  items: ItemsConnection;
  name: Scalars['String'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
};


/** Type item that is part of a category */
export type TypeItemEditSuggestionsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemEditSuggestionCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};


/** Type item that is part of a category */
export type TypeItemsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
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
  name: Scalars['ShortText'];
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

/** All input for the `updateCheckInCommentByNodeId` mutation. */
export type UpdateCheckInCommentByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckInComment` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `CheckInComment` being updated. */
  patch: CheckInCommentPatch;
};

/** All input for the `updateCheckInComment` mutation. */
export type UpdateCheckInCommentInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `CheckInComment` being updated. */
  patch: CheckInCommentPatch;
};

/** The output of our update `CheckInComment` mutation. */
export type UpdateCheckInCommentPayload = {
  __typename?: 'UpdateCheckInCommentPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInComment`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInComment` that was updated by this mutation. */
  checkInComment: Maybe<CheckInComment>;
  /** An edge for our `CheckInComment`. May be used by Relay 1. */
  checkInCommentEdge: Maybe<CheckInCommentsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CheckInComment`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our update `CheckInComment` mutation. */
export type UpdateCheckInCommentPayloadCheckInCommentEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInCommentsOrderBy>>;
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

/** All input for the `updateCheckInLikeByNodeId` mutation. */
export type UpdateCheckInLikeByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckInLike` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `CheckInLike` being updated. */
  patch: CheckInLikePatch;
};

/** All input for the `updateCheckInLike` mutation. */
export type UpdateCheckInLikeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `CheckInLike` being updated. */
  patch: CheckInLikePatch;
};

/** The output of our update `CheckInLike` mutation. */
export type UpdateCheckInLikePayload = {
  __typename?: 'UpdateCheckInLikePayload';
  /** Reads a single `CheckIn` that is related to this `CheckInLike`. */
  checkInById: Maybe<CheckIn>;
  /** The `CheckInLike` that was updated by this mutation. */
  checkInLike: Maybe<CheckInLike>;
  /** An edge for our `CheckInLike`. May be used by Relay 1. */
  checkInLikeEdge: Maybe<CheckInLikesEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CheckInLike`. */
  userByLikedBy: Maybe<User>;
};


/** The output of our update `CheckInLike` mutation. */
export type UpdateCheckInLikePayloadCheckInLikeEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInLikesOrderBy>>;
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
  /** Reads a single `Item` that is related to this `CheckIn`. */
  item: Maybe<Item>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
};


/** The output of our update `CheckIn` mutation. */
export type UpdateCheckInPayloadCheckInEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInsOrderBy>>;
};

/** All input for the `updateCheckInTagByNodeId` mutation. */
export type UpdateCheckInTagByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CheckInTag` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `CheckInTag` being updated. */
  patch: CheckInTagPatch;
};

/** All input for the `updateCheckInTag` mutation. */
export type UpdateCheckInTagInput = {
  checkInId: Scalars['Int'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** An object where the defined keys will be set on the `CheckInTag` being updated. */
  patch: CheckInTagPatch;
  tagId: Scalars['Int'];
};

/** The output of our update `CheckInTag` mutation. */
export type UpdateCheckInTagPayload = {
  __typename?: 'UpdateCheckInTagPayload';
  /** Reads a single `CheckIn` that is related to this `CheckInTag`. */
  checkIn: Maybe<CheckIn>;
  /** The `CheckInTag` that was updated by this mutation. */
  checkInTag: Maybe<CheckInTag>;
  /** An edge for our `CheckInTag`. May be used by Relay 1. */
  checkInTagEdge: Maybe<CheckInTagsEdge>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Tag` that is related to this `CheckInTag`. */
  tag: Maybe<Tag>;
};


/** The output of our update `CheckInTag` mutation. */
export type UpdateCheckInTagPayloadCheckInTagEdgeArgs = {
  orderBy?: InputMaybe<Array<CheckInTagsOrderBy>>;
};

/** All input for the `updateCompanyByName` mutation. */
export type UpdateCompanyByNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
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

/** All input for the `updateCompanyLikeByNodeId` mutation. */
export type UpdateCompanyLikeByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `CompanyLike` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `CompanyLike` being updated. */
  patch: CompanyLikePatch;
};

/** All input for the `updateCompanyLike` mutation. */
export type UpdateCompanyLikeInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  likedBy: Scalars['UUID'];
  /** An object where the defined keys will be set on the `CompanyLike` being updated. */
  patch: CompanyLikePatch;
};

/** The output of our update `CompanyLike` mutation. */
export type UpdateCompanyLikePayload = {
  __typename?: 'UpdateCompanyLikePayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Company` that is related to this `CompanyLike`. */
  companyById: Maybe<Company>;
  /** The `CompanyLike` that was updated by this mutation. */
  companyLike: Maybe<CompanyLike>;
  /** An edge for our `CompanyLike`. May be used by Relay 1. */
  companyLikeEdge: Maybe<CompanyLikesEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `CompanyLike`. */
  userByLikedBy: Maybe<User>;
};


/** The output of our update `CompanyLike` mutation. */
export type UpdateCompanyLikePayloadCompanyLikeEdgeArgs = {
  orderBy?: InputMaybe<Array<CompanyLikesOrderBy>>;
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

/** All input for the `updateFriendByNodeId` mutation. */
export type UpdateFriendByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Friend` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Friend` being updated. */
  patch: FriendPatch;
};

/** All input for the `updateFriend` mutation. */
export type UpdateFriendInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** An object where the defined keys will be set on the `Friend` being updated. */
  patch: FriendPatch;
  userId1: Scalars['UUID'];
  userId2: Scalars['UUID'];
};

/** The output of our update `Friend` mutation. */
export type UpdateFriendPayload = {
  __typename?: 'UpdateFriendPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Friend` that was updated by this mutation. */
  friend: Maybe<Friend>;
  /** An edge for our `Friend`. May be used by Relay 1. */
  friendEdge: Maybe<FriendsEdge>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByBlockedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId1: Maybe<User>;
  /** Reads a single `User` that is related to this `Friend`. */
  userByUserId2: Maybe<User>;
};


/** The output of our update `Friend` mutation. */
export type UpdateFriendPayloadFriendEdgeArgs = {
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};

/** All input for the `updateItemByBrandIdAndFlavor` mutation. */
export type UpdateItemByBrandIdAndFlavorInput = {
  brandId: Scalars['Int'];
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  flavor: Scalars['String'];
  /** An object where the defined keys will be set on the `Item` being updated. */
  patch: ItemPatch;
};

/** All input for the `updateItemByNodeId` mutation. */
export type UpdateItemByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Item` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Item` being updated. */
  patch: ItemPatch;
};

/** All input for the `updateItemEditSuggestionByNodeId` mutation. */
export type UpdateItemEditSuggestionByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `ItemEditSuggestion` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `ItemEditSuggestion` being updated. */
  patch: ItemEditSuggestionPatch;
};

/** All input for the `updateItemEditSuggestion` mutation. */
export type UpdateItemEditSuggestionInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `ItemEditSuggestion` being updated. */
  patch: ItemEditSuggestionPatch;
};

/** The output of our update `ItemEditSuggestion` mutation. */
export type UpdateItemEditSuggestionPayload = {
  __typename?: 'UpdateItemEditSuggestionPayload';
  /** Reads a single `User` that is related to this `ItemEditSuggestion`. */
  author: Maybe<User>;
  /** Reads a single `Brand` that is related to this `ItemEditSuggestion`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Reads a single `Item` that is related to this `ItemEditSuggestion`. */
  item: Maybe<Item>;
  /** The `ItemEditSuggestion` that was updated by this mutation. */
  itemEditSuggestion: Maybe<ItemEditSuggestion>;
  /** An edge for our `ItemEditSuggestion`. May be used by Relay 1. */
  itemEditSuggestionEdge: Maybe<ItemEditSuggestionsEdge>;
  /** Reads a single `Company` that is related to this `ItemEditSuggestion`. */
  manufacturer: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `ItemEditSuggestion`. */
  type: Maybe<Type>;
};


/** The output of our update `ItemEditSuggestion` mutation. */
export type UpdateItemEditSuggestionPayloadItemEditSuggestionEdgeArgs = {
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
};

/** All input for the `updateItem` mutation. */
export type UpdateItemInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `Item` being updated. */
  patch: ItemPatch;
};

/** The output of our update `Item` mutation. */
export type UpdateItemPayload = {
  __typename?: 'UpdateItemPayload';
  /** Reads a single `Brand` that is related to this `Item`. */
  brand: Maybe<Brand>;
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** The `Item` that was updated by this mutation. */
  item: Maybe<Item>;
  /** An edge for our `Item`. May be used by Relay 1. */
  itemEdge: Maybe<ItemsEdge>;
  /** Reads a single `Company` that is related to this `Item`. */
  manufacturer: Maybe<Company>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `Type` that is related to this `Item`. */
  type: Maybe<Type>;
  /** Reads a single `User` that is related to this `Item`. */
  userByCreatedBy: Maybe<User>;
  /** Reads a single `User` that is related to this `Item`. */
  userByUpdatedBy: Maybe<User>;
};


/** The output of our update `Item` mutation. */
export type UpdateItemPayloadItemEdgeArgs = {
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};

/** All input for the `updateTagByName` mutation. */
export type UpdateTagByNameInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
  /** An object where the defined keys will be set on the `Tag` being updated. */
  patch: TagPatch;
};

/** All input for the `updateTagByNodeId` mutation. */
export type UpdateTagByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `Tag` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `Tag` being updated. */
  patch: TagPatch;
};

/** All input for the `updateTag` mutation. */
export type UpdateTagInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['Int'];
  /** An object where the defined keys will be set on the `Tag` being updated. */
  patch: TagPatch;
};

/** The output of our update `Tag` mutation. */
export type UpdateTagPayload = {
  __typename?: 'UpdateTagPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** The `Tag` that was updated by this mutation. */
  tag: Maybe<Tag>;
  /** An edge for our `Tag`. May be used by Relay 1. */
  tagEdge: Maybe<TagsEdge>;
  /** Reads a single `User` that is related to this `Tag`. */
  userByCreatedBy: Maybe<User>;
};


/** The output of our update `Tag` mutation. */
export type UpdateTagPayloadTagEdgeArgs = {
  orderBy?: InputMaybe<Array<TagsOrderBy>>;
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

/** All input for the `updateUserAuthenticationByNodeId` mutation. */
export type UpdateUserAuthenticationByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `UserAuthentication` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `UserAuthentication` being updated. */
  patch: UserAuthenticationPatch;
};

/** All input for the `updateUserAuthentication` mutation. */
export type UpdateUserAuthenticationInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
  /** An object where the defined keys will be set on the `UserAuthentication` being updated. */
  patch: UserAuthenticationPatch;
};

/** The output of our update `UserAuthentication` mutation. */
export type UpdateUserAuthenticationPayload = {
  __typename?: 'UpdateUserAuthenticationPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserAuthentication`. */
  user: Maybe<User>;
  /** The `UserAuthentication` that was updated by this mutation. */
  userAuthentication: Maybe<UserAuthentication>;
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
  /** Public-facing username (or 'handle') of the user. */
  username: Scalars['String'];
};

/** All input for the `updateUserEmailByNodeId` mutation. */
export type UpdateUserEmailByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `UserEmail` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `UserEmail` being updated. */
  patch: UserEmailPatch;
};

/** All input for the `updateUserEmail` mutation. */
export type UpdateUserEmailInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
  /** An object where the defined keys will be set on the `UserEmail` being updated. */
  patch: UserEmailPatch;
};

/** The output of our update `UserEmail` mutation. */
export type UpdateUserEmailPayload = {
  __typename?: 'UpdateUserEmailPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserEmail`. */
  user: Maybe<User>;
  /** The `UserEmail` that was updated by this mutation. */
  userEmail: Maybe<UserEmail>;
  /** An edge for our `UserEmail`. May be used by Relay 1. */
  userEmailEdge: Maybe<UserEmailsEdge>;
};


/** The output of our update `UserEmail` mutation. */
export type UpdateUserEmailPayloadUserEmailEdgeArgs = {
  orderBy?: InputMaybe<Array<UserEmailsOrderBy>>;
};

/** All input for the `updateUser` mutation. */
export type UpdateUserInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** Unique identifier for the user. */
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

/** All input for the `updateUserSettingByNodeId` mutation. */
export type UpdateUserSettingByNodeIdInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  /** The globally unique `ID` which will identify a single `UserSetting` to be updated. */
  nodeId: Scalars['ID'];
  /** An object where the defined keys will be set on the `UserSetting` being updated. */
  patch: UserSettingPatch;
};

/** All input for the `updateUserSetting` mutation. */
export type UpdateUserSettingInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  id: Scalars['UUID'];
  /** An object where the defined keys will be set on the `UserSetting` being updated. */
  patch: UserSettingPatch;
};

/** The output of our update `UserSetting` mutation. */
export type UpdateUserSettingPayload = {
  __typename?: 'UpdateUserSettingPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  /** Reads a single `User` that is related to this `UserSetting`. */
  userById: Maybe<User>;
  /** The `UserSetting` that was updated by this mutation. */
  userSetting: Maybe<UserSetting>;
  /** An edge for our `UserSetting`. May be used by Relay 1. */
  userSettingEdge: Maybe<UserSettingsEdge>;
};


/** The output of our update `UserSetting` mutation. */
export type UpdateUserSettingPayloadUserSettingEdgeArgs = {
  orderBy?: InputMaybe<Array<UserSettingsOrderBy>>;
};

/** A user who can log in to the application. */
export type User = Node & {
  __typename?: 'User';
  /** Reads and enables pagination through a set of `ActivityFeed`. */
  authoredActivityFeeds: ActivityFeedsConnection;
  /** Reads and enables pagination through a set of `CheckIn`. */
  authoredCheckIns: CheckInsConnection;
  /** Reads and enables pagination through a set of `ItemEditSuggestion`. */
  authoredItemEditSuggestions: ItemEditSuggestionsConnection;
  /** Optional avatar URL. */
  avatarUrl: Maybe<Scalars['String']>;
  /** Reads and enables pagination through a set of `Brand`. */
  brandsByCreatedBy: BrandsConnection;
  /** Reads and enables pagination through a set of `CheckInComment`. */
  checkInCommentsByCreatedBy: CheckInCommentsConnection;
  /** Reads and enables pagination through a set of `CheckInFriend`. */
  checkInFriendsByFriendId: CheckInFriendsConnection;
  /** Reads and enables pagination through a set of `CheckInLike`. */
  checkInLikesByLikedBy: CheckInLikesConnection;
  /** Reads and enables pagination through a set of `Company`. */
  companiesByCreatedBy: CompaniesConnection;
  /** Reads and enables pagination through a set of `CompanyLike`. */
  companyLikesByLikedBy: CompanyLikesConnection;
  country: Maybe<Scalars['String']>;
  createdAt: Scalars['Datetime'];
  firstName: Maybe<Scalars['String']>;
  friendStatus: UsersFriendStatusConnection;
  friends: UsersFriendsConnection;
  /** Reads and enables pagination through a set of `Friend`. */
  friendsByBlockedBy: FriendsConnection;
  /** Reads and enables pagination through a set of `Friend`. */
  friendsByUserId1: FriendsConnection;
  /** Reads and enables pagination through a set of `Friend`. */
  friendsByUserId2: FriendsConnection;
  hasPassword: Maybe<Scalars['Boolean']>;
  /** Unique identifier for the user. */
  id: Scalars['UUID'];
  /** If true, the user has elevated privileges. */
  isAdmin: Scalars['Boolean'];
  isVerified: Scalars['Boolean'];
  /** Reads and enables pagination through a set of `Item`. */
  itemsByCreatedBy: ItemsConnection;
  /** Reads and enables pagination through a set of `Item`. */
  itemsByUpdatedBy: ItemsConnection;
  lastName: Maybe<Scalars['String']>;
  location: Maybe<Scalars['String']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads and enables pagination through a set of `Tag`. */
  tagsByCreatedBy: TagsConnection;
  totalCheckIns: Maybe<Scalars['Int']>;
  totalFriends: Maybe<Scalars['Int']>;
  uniqueCheckIns: Maybe<Scalars['Int']>;
  updatedAt: Scalars['Datetime'];
  /** Reads and enables pagination through a set of `UserAuthentication`. */
  userAuthenticationsList: Array<UserAuthentication>;
  /** Reads and enables pagination through a set of `UserEmail`. */
  userEmails: UserEmailsConnection;
  /** Reads a single `UserSetting` that is related to this `User`. */
  userSettingById: Maybe<UserSetting>;
  /**
   * Reads and enables pagination through a set of `UserSetting`.
   * @deprecated Please use userSettingById instead
   */
  userSettingsById: UserSettingsConnection;
  /** Public-facing username (or 'handle') of the user. */
  username: Scalars['String'];
};


/** A user who can log in to the application. */
export type UserAuthoredActivityFeedsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ActivityFeedCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ActivityFeedsOrderBy>>;
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
export type UserAuthoredItemEditSuggestionsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemEditSuggestionCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemEditSuggestionsOrderBy>>;
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
export type UserCheckInCommentsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInCommentCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInCommentsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserCheckInFriendsByFriendIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInFriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInFriendsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserCheckInLikesByLikedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CheckInLikeCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CheckInLikesOrderBy>>;
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
export type UserCompanyLikesByLikedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<CompanyLikeCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<CompanyLikesOrderBy>>;
};


/** A user who can log in to the application. */
export type UserFriendStatusArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
};


/** A user who can log in to the application. */
export type UserFriendsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
};


/** A user who can log in to the application. */
export type UserFriendsByBlockedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<FriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserFriendsByUserId1Args = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<FriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserFriendsByUserId2Args = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<FriendCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<FriendsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserItemsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserItemsByUpdatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<ItemCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<ItemsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserTagsByCreatedByArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<TagCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<TagsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserUserAuthenticationsListArgs = {
  condition: InputMaybe<UserAuthenticationCondition>;
  first: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy: InputMaybe<Array<UserAuthenticationsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserUserEmailsArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<UserEmailCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<UserEmailsOrderBy>>;
};


/** A user who can log in to the application. */
export type UserUserSettingsByIdArgs = {
  after: InputMaybe<Scalars['Cursor']>;
  before: InputMaybe<Scalars['Cursor']>;
  condition: InputMaybe<UserSettingCondition>;
  first: InputMaybe<Scalars['Int']>;
  last: InputMaybe<Scalars['Int']>;
  offset: InputMaybe<Scalars['Int']>;
  orderBy?: InputMaybe<Array<UserSettingsOrderBy>>;
};

/** Contains information about the login providers this user has used, so that they may disconnect them should they wish. */
export type UserAuthentication = Node & {
  __typename?: 'UserAuthentication';
  createdAt: Scalars['Datetime'];
  id: Scalars['UUID'];
  /** A unique identifier for the user within the login service. */
  identifier: Scalars['String'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** The login service used, e.g. `twitter` or `github`. */
  service: Scalars['String'];
  updatedAt: Scalars['Datetime'];
  /** Reads a single `User` that is related to this `UserAuthentication`. */
  user: Maybe<User>;
  userId: Scalars['UUID'];
};

/**
 * A condition to be used against `UserAuthentication` object types. All fields are
 * tested for equality and combined with a logical ‘and.’
 */
export type UserAuthenticationCondition = {
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `identifier` field. */
  identifier: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `service` field. */
  service: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `userId` field. */
  userId: InputMaybe<Scalars['UUID']>;
};

/** An input for mutations affecting `UserAuthentication` */
export type UserAuthenticationInput = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['UUID']>;
  /** A unique identifier for the user within the login service. */
  identifier: Scalars['String'];
  /** The login service used, e.g. `twitter` or `github`. */
  service: Scalars['String'];
  updatedAt: InputMaybe<Scalars['Datetime']>;
  userId: Scalars['UUID'];
};

/** Represents an update to a `UserAuthentication`. Fields that are set will be updated. */
export type UserAuthenticationPatch = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  id: InputMaybe<Scalars['UUID']>;
  /** A unique identifier for the user within the login service. */
  identifier: InputMaybe<Scalars['String']>;
  /** The login service used, e.g. `twitter` or `github`. */
  service: InputMaybe<Scalars['String']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  userId: InputMaybe<Scalars['UUID']>;
};

/** Methods to use when ordering `UserAuthentication`. */
export enum UserAuthenticationsOrderBy {
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  IdentifierAsc = 'IDENTIFIER_ASC',
  IdentifierDesc = 'IDENTIFIER_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  ServiceAsc = 'SERVICE_ASC',
  ServiceDesc = 'SERVICE_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UserIdAsc = 'USER_ID_ASC',
  UserIdDesc = 'USER_ID_DESC'
}

/** Information about a user's email address. */
export type UserEmail = Node & {
  __typename?: 'UserEmail';
  createdAt: Scalars['Datetime'];
  /** The users email address, in `a@b.c` format. */
  email: Scalars['String'];
  id: Scalars['UUID'];
  isPrimary: Scalars['Boolean'];
  /** True if the user has is_verified their email address (by clicking the link in the email we sent them, or logging in with a social login provider), false otherwise. */
  isVerified: Scalars['Boolean'];
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  updatedAt: Scalars['Datetime'];
  /** Reads a single `User` that is related to this `UserEmail`. */
  user: Maybe<User>;
  userId: Scalars['UUID'];
};

/**
 * A condition to be used against `UserEmail` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type UserEmailCondition = {
  /** Checks for equality with the object’s `createdAt` field. */
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `email` field. */
  email: InputMaybe<Scalars['String']>;
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `isPrimary` field. */
  isPrimary: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `isVerified` field. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `updatedAt` field. */
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Checks for equality with the object’s `userId` field. */
  userId: InputMaybe<Scalars['UUID']>;
};

/** An input for mutations affecting `UserEmail` */
export type UserEmailInput = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** The users email address, in `a@b.c` format. */
  email: Scalars['String'];
  id: InputMaybe<Scalars['UUID']>;
  isPrimary: InputMaybe<Scalars['Boolean']>;
  /** True if the user has is_verified their email address (by clicking the link in the email we sent them, or logging in with a social login provider), false otherwise. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  userId: InputMaybe<Scalars['UUID']>;
};

/** Represents an update to a `UserEmail`. Fields that are set will be updated. */
export type UserEmailPatch = {
  createdAt: InputMaybe<Scalars['Datetime']>;
  /** The users email address, in `a@b.c` format. */
  email: InputMaybe<Scalars['String']>;
  id: InputMaybe<Scalars['UUID']>;
  isPrimary: InputMaybe<Scalars['Boolean']>;
  /** True if the user has is_verified their email address (by clicking the link in the email we sent them, or logging in with a social login provider), false otherwise. */
  isVerified: InputMaybe<Scalars['Boolean']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  userId: InputMaybe<Scalars['UUID']>;
};

/** A connection to a list of `UserEmail` values. */
export type UserEmailsConnection = {
  __typename?: 'UserEmailsConnection';
  /** A list of edges which contains the `UserEmail` and cursor to aid in pagination. */
  edges: Array<UserEmailsEdge>;
  /** A list of `UserEmail` objects. */
  nodes: Array<Maybe<UserEmail>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `UserEmail` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `UserEmail` edge in the connection. */
export type UserEmailsEdge = {
  __typename?: 'UserEmailsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `UserEmail` at the end of the edge. */
  node: Maybe<UserEmail>;
};

/** Methods to use when ordering `UserEmail`. */
export enum UserEmailsOrderBy {
  CreatedAtAsc = 'CREATED_AT_ASC',
  CreatedAtDesc = 'CREATED_AT_DESC',
  EmailAsc = 'EMAIL_ASC',
  EmailDesc = 'EMAIL_DESC',
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsPrimaryAsc = 'IS_PRIMARY_ASC',
  IsPrimaryDesc = 'IS_PRIMARY_DESC',
  IsVerifiedAsc = 'IS_VERIFIED_ASC',
  IsVerifiedDesc = 'IS_VERIFIED_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UserIdAsc = 'USER_ID_ASC',
  UserIdDesc = 'USER_ID_DESC'
}

/** An input for mutations affecting `User` */
export type UserInput = {
  /** Optional avatar URL. */
  avatarUrl: InputMaybe<Scalars['String']>;
  country: InputMaybe<Scalars['String']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  firstName: InputMaybe<Scalars['String']>;
  /** Unique identifier for the user. */
  id: InputMaybe<Scalars['UUID']>;
  /** If true, the user has elevated privileges. */
  isAdmin: InputMaybe<Scalars['Boolean']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  lastName: InputMaybe<Scalars['String']>;
  location: InputMaybe<Scalars['String']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Public-facing username (or 'handle') of the user. */
  username: Scalars['String'];
};

/** Represents an update to a `User`. Fields that are set will be updated. */
export type UserPatch = {
  /** Optional avatar URL. */
  avatarUrl: InputMaybe<Scalars['String']>;
  country: InputMaybe<Scalars['String']>;
  createdAt: InputMaybe<Scalars['Datetime']>;
  firstName: InputMaybe<Scalars['String']>;
  /** Unique identifier for the user. */
  id: InputMaybe<Scalars['UUID']>;
  /** If true, the user has elevated privileges. */
  isAdmin: InputMaybe<Scalars['Boolean']>;
  isVerified: InputMaybe<Scalars['Boolean']>;
  lastName: InputMaybe<Scalars['String']>;
  location: InputMaybe<Scalars['String']>;
  updatedAt: InputMaybe<Scalars['Datetime']>;
  /** Public-facing username (or 'handle') of the user. */
  username: InputMaybe<Scalars['String']>;
};

export type UserSetting = Node & {
  __typename?: 'UserSetting';
  id: Scalars['UUID'];
  isPublic: Maybe<Scalars['Boolean']>;
  isPublicCheckIns: Maybe<Scalars['Boolean']>;
  /** A globally unique identifier. Can be used in various places throughout the system to identify this single value. */
  nodeId: Scalars['ID'];
  /** Reads a single `User` that is related to this `UserSetting`. */
  userById: Maybe<User>;
};

/**
 * A condition to be used against `UserSetting` object types. All fields are tested
 * for equality and combined with a logical ‘and.’
 */
export type UserSettingCondition = {
  /** Checks for equality with the object’s `id` field. */
  id: InputMaybe<Scalars['UUID']>;
  /** Checks for equality with the object’s `isPublic` field. */
  isPublic: InputMaybe<Scalars['Boolean']>;
  /** Checks for equality with the object’s `isPublicCheckIns` field. */
  isPublicCheckIns: InputMaybe<Scalars['Boolean']>;
};

/** An input for mutations affecting `UserSetting` */
export type UserSettingInput = {
  id: Scalars['UUID'];
  isPublic: InputMaybe<Scalars['Boolean']>;
  isPublicCheckIns: InputMaybe<Scalars['Boolean']>;
};

/** Represents an update to a `UserSetting`. Fields that are set will be updated. */
export type UserSettingPatch = {
  id: InputMaybe<Scalars['UUID']>;
  isPublic: InputMaybe<Scalars['Boolean']>;
  isPublicCheckIns: InputMaybe<Scalars['Boolean']>;
};

/** A connection to a list of `UserSetting` values. */
export type UserSettingsConnection = {
  __typename?: 'UserSettingsConnection';
  /** A list of edges which contains the `UserSetting` and cursor to aid in pagination. */
  edges: Array<UserSettingsEdge>;
  /** A list of `UserSetting` objects. */
  nodes: Array<Maybe<UserSetting>>;
  /** Information to aid in pagination. */
  pageInfo: PageInfo;
  /** The count of *all* `UserSetting` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `UserSetting` edge in the connection. */
export type UserSettingsEdge = {
  __typename?: 'UserSettingsEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `UserSetting` at the end of the edge. */
  node: Maybe<UserSetting>;
};

/** Methods to use when ordering `UserSetting`. */
export enum UserSettingsOrderBy {
  IdAsc = 'ID_ASC',
  IdDesc = 'ID_DESC',
  IsPublicAsc = 'IS_PUBLIC_ASC',
  IsPublicCheckInsAsc = 'IS_PUBLIC_CHECK_INS_ASC',
  IsPublicCheckInsDesc = 'IS_PUBLIC_CHECK_INS_DESC',
  IsPublicDesc = 'IS_PUBLIC_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC'
}

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

/** A `UsersFriendsRecord` edge in the connection. */
export type UsersFriendEdge = {
  __typename?: 'UsersFriendEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `UsersFriendsRecord` at the end of the edge. */
  node: Maybe<UsersFriendsRecord>;
};

/** A connection to a list of `UsersFriendStatusRecord` values. */
export type UsersFriendStatusConnection = {
  __typename?: 'UsersFriendStatusConnection';
  /** A list of edges which contains the `UsersFriendStatusRecord` and cursor to aid in pagination. */
  edges: Array<UsersFriendStatusEdge>;
  /** A list of `UsersFriendStatusRecord` objects. */
  nodes: Array<Maybe<UsersFriendStatusRecord>>;
  /** The count of *all* `UsersFriendStatusRecord` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** A `UsersFriendStatusRecord` edge in the connection. */
export type UsersFriendStatusEdge = {
  __typename?: 'UsersFriendStatusEdge';
  /** A cursor for use in pagination. */
  cursor: Maybe<Scalars['Cursor']>;
  /** The `UsersFriendStatusRecord` at the end of the edge. */
  node: Maybe<UsersFriendStatusRecord>;
};

/** The return type of our `friendStatus` query. */
export type UsersFriendStatusRecord = {
  __typename?: 'UsersFriendStatusRecord';
  isSender: Maybe<Scalars['Boolean']>;
  status: Maybe<FriendStatus>;
};

/** A connection to a list of `UsersFriendsRecord` values. */
export type UsersFriendsConnection = {
  __typename?: 'UsersFriendsConnection';
  /** A list of edges which contains the `UsersFriendsRecord` and cursor to aid in pagination. */
  edges: Array<UsersFriendEdge>;
  /** A list of `UsersFriendsRecord` objects. */
  nodes: Array<Maybe<UsersFriendsRecord>>;
  /** The count of *all* `UsersFriendsRecord` you could get from the connection. */
  totalCount: Scalars['Int'];
};

/** The return type of our `friends` query. */
export type UsersFriendsRecord = {
  __typename?: 'UsersFriendsRecord';
  avatarUrl: Maybe<Scalars['String']>;
  firstName: Maybe<Scalars['String']>;
  id: Maybe<Scalars['UUID']>;
  isSender: Maybe<Scalars['Boolean']>;
  lastName: Maybe<Scalars['String']>;
  status: Maybe<FriendStatus>;
  username: Maybe<Scalars['String']>;
};

/** Methods to use when ordering `User`. */
export enum UsersOrderBy {
  AvatarUrlAsc = 'AVATAR_URL_ASC',
  AvatarUrlDesc = 'AVATAR_URL_DESC',
  CountryAsc = 'COUNTRY_ASC',
  CountryDesc = 'COUNTRY_DESC',
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
  LocationAsc = 'LOCATION_ASC',
  LocationDesc = 'LOCATION_DESC',
  Natural = 'NATURAL',
  PrimaryKeyAsc = 'PRIMARY_KEY_ASC',
  PrimaryKeyDesc = 'PRIMARY_KEY_DESC',
  UpdatedAtAsc = 'UPDATED_AT_ASC',
  UpdatedAtDesc = 'UPDATED_AT_DESC',
  UsernameAsc = 'USERNAME_ASC',
  UsernameDesc = 'USERNAME_DESC'
}

/** All input for the `verifyEmail` mutation. */
export type VerifyEmailInput = {
  /**
   * An arbitrary string value with no semantic meaning. Will be included in the
   * payload verbatim. May be used to track mutations by the client.
   */
  clientMutationId: InputMaybe<Scalars['String']>;
  token: Scalars['String'];
  userEmailId: Scalars['UUID'];
};

/** The output of our `verifyEmail` mutation. */
export type VerifyEmailPayload = {
  __typename?: 'VerifyEmailPayload';
  /**
   * The exact same `clientMutationId` that was provided in the mutation input,
   * unchanged and unused. May be used by a client to track mutations.
   */
  clientMutationId: Maybe<Scalars['String']>;
  /** Our root query field type. Allows us to run any query from our mutation payload. */
  query: Maybe<Query>;
  success: Maybe<Scalars['Boolean']>;
};

export type GetCompaniesQueryVariables = Exact<{ [key: string]: never; }>;


export type GetCompaniesQuery = { __typename?: 'Query', companies: { __typename?: 'CompaniesConnection', nodes: Array<{ __typename?: 'Company', id: number, name: string, brands: { __typename?: 'BrandsConnection', nodes: Array<{ __typename?: 'Brand', id: number, name: any }> } }> } };


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

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    getCompanies(variables?: GetCompaniesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GetCompaniesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GetCompaniesQuery>(GetCompaniesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getCompanies');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;