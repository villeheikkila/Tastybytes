import { GraphQLResolveInfo, GraphQLScalarType, GraphQLScalarTypeConfig } from 'graphql';
export type Maybe<T> = T | null;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type RequireFields<T, K extends keyof T> = { [X in Exclude<keyof T, K>]?: T[X] } & { [P in K]-?: NonNullable<T[P]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  /** The javascript `Date` as string. Type represents date and time as the ISO Date string. */
  DateTime: any;
  /** The `Upload` scalar type represents a file upload. */
  Upload: any;
};

export type Account = {
  __typename?: 'Account';
  avatarUri?: Maybe<Scalars['String']>;
  createdDate: Scalars['DateTime'];
  createdTreats: Array<Treat>;
  email: Scalars['String'];
  firstName: Scalars['String'];
  id: Scalars['ID'];
  isVerified: Scalars['Boolean'];
  lastName: Scalars['String'];
  passwordHash: Scalars['String'];
  reviews: Array<Review>;
  role?: Maybe<Scalars['String']>;
  updatedDate: Scalars['DateTime'];
  username: Scalars['String'];
};

export type AccountInput = {
  captchaToken: Scalars['String'];
  email: Scalars['String'];
  firstName?: Maybe<Scalars['String']>;
  lastName?: Maybe<Scalars['String']>;
  password: Scalars['String'];
  username: Scalars['String'];
};

export type Category = {
  __typename?: 'Category';
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  id: Scalars['ID'];
  isPublished: Scalars['Boolean'];
  name: Scalars['String'];
  subcategories: Array<Subcategory>;
  treats: Array<Treat>;
  updatedBy: Account;
  updatedDate: Scalars['DateTime'];
};

export type Company = {
  __typename?: 'Company';
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  id: Scalars['ID'];
  isPublished: Scalars['Boolean'];
  name: Scalars['String'];
  treats: Array<Treat>;
  updatedBy: Account;
  updatedDate: Scalars['DateTime'];
};


export type ExtendedBaseEntity = {
  __typename?: 'ExtendedBaseEntity';
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  id: Scalars['ID'];
  updatedBy: Account;
  updatedDate: Scalars['DateTime'];
};

export type Image = {
  __typename?: 'Image';
  avatarUri: Scalars['String'];
  filename: Scalars['String'];
};

export type LogInInput = {
  password: Scalars['String'];
  username: Scalars['String'];
};

/** Return values for the login query. */
export enum LoginResult {
  IncorrectPassword = 'INCORRECT_PASSWORD',
  InexistentAccount = 'INEXISTENT_ACCOUNT',
  Success = 'SUCCESS',
  UnverifiedAccount = 'UNVERIFIED_ACCOUNT'
}

export type Mutation = {
  __typename?: 'Mutation';
  createAccount: Account;
  createCategory: Category;
  createCompany: Company;
  createReview: Review;
  createSubcategory: Subcategory;
  createTreat: Treat;
  deleteAccount: Scalars['Boolean'];
  deleteCategory: Scalars['Boolean'];
  deleteCompany: Scalars['Boolean'];
  deleteSubategory: Scalars['Boolean'];
  resetPassword: Scalars['Boolean'];
  updateAccount: Account;
  uploadProfilePicture: Image;
  verifyAccount: Scalars['Boolean'];
};


export type MutationCreateAccountArgs = {
  account: AccountInput;
};


export type MutationCreateCategoryArgs = {
  name: Scalars['String'];
};


export type MutationCreateCompanyArgs = {
  name: Scalars['String'];
};


export type MutationCreateReviewArgs = {
  review: ReviewInput;
};


export type MutationCreateSubcategoryArgs = {
  categoryId: Scalars['ID'];
  name: Scalars['String'];
};


export type MutationCreateTreatArgs = {
  categoryId: Scalars['ID'];
  companyId: Scalars['ID'];
  name: Scalars['String'];
  subcategoryId: Scalars['ID'];
};


export type MutationDeleteCategoryArgs = {
  id: Scalars['ID'];
};


export type MutationDeleteCompanyArgs = {
  id: Scalars['ID'];
};


export type MutationDeleteSubategoryArgs = {
  id: Scalars['ID'];
};


export type MutationResetPasswordArgs = {
  password: Scalars['String'];
  token: Scalars['String'];
};


export type MutationUpdateAccountArgs = {
  account: UpdateAccountInput;
};


export type MutationUploadProfilePictureArgs = {
  picture: Scalars['Upload'];
};


export type MutationVerifyAccountArgs = {
  token: Scalars['String'];
};

export type Query = {
  __typename?: 'Query';
  account: Account;
  accounts: Array<Account>;
  categories: Array<Category>;
  category: Category;
  companies: Array<Company>;
  company: Company;
  currentAccount: Account;
  logIn: LoginResult;
  logOut: Scalars['Boolean'];
  requestAccountVerification: Scalars['Boolean'];
  requestPasswordReset: Scalars['Boolean'];
  reviews: Array<Review>;
  searchTreats: Array<Treat>;
  subcategories: Array<Subcategory>;
  subcategoriesByCategory: Array<Subcategory>;
  subcategory: Subcategory;
  treat: Treat;
  treats: Array<Treat>;
};


export type QueryAccountArgs = {
  id: Scalars['ID'];
};


export type QueryCategoryArgs = {
  id: Scalars['ID'];
};


export type QueryCompanyArgs = {
  id: Scalars['ID'];
};


export type QueryLogInArgs = {
  account: LogInInput;
};


export type QueryRequestAccountVerificationArgs = {
  username: Scalars['String'];
};


export type QueryRequestPasswordResetArgs = {
  email: Scalars['String'];
};


export type QueryReviewsArgs = {
  offset: Scalars['Float'];
};


export type QuerySearchTreatsArgs = {
  offset?: Maybe<Scalars['Float']>;
  searchTerm: Scalars['String'];
};


export type QuerySubcategoriesByCategoryArgs = {
  categoryId: Scalars['ID'];
};


export type QuerySubcategoryArgs = {
  id?: Maybe<Scalars['ID']>;
};


export type QueryTreatArgs = {
  id: Scalars['ID'];
};

export type Review = {
  __typename?: 'Review';
  author: Account;
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  id: Scalars['ID'];
  review: Scalars['String'];
  score: Scalars['Float'];
  treat: Treat;
  updatedBy: Account;
  updatedDate: Scalars['DateTime'];
};

export type ReviewInput = {
  review?: Maybe<Scalars['String']>;
  score: Scalars['Int'];
  treatId: Scalars['ID'];
};

export type Subcategory = {
  __typename?: 'Subcategory';
  category: Category;
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  id: Scalars['ID'];
  isPublished: Scalars['Boolean'];
  name: Scalars['String'];
  treats: Array<Treat>;
  updatedBy: Account;
  updatedDate: Scalars['DateTime'];
};

export type Treat = {
  __typename?: 'Treat';
  category: Category;
  company: Company;
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  id: Scalars['ID'];
  name: Scalars['String'];
  reviews: Array<Review>;
  subcategory: Subcategory;
  updatedBy: Account;
  updatedDate: Scalars['DateTime'];
};

export type UpdateAccountInput = {
  email?: Maybe<Scalars['String']>;
  firstName?: Maybe<Scalars['String']>;
  lastName?: Maybe<Scalars['String']>;
  password?: Maybe<Scalars['String']>;
  username?: Maybe<Scalars['String']>;
};




export type ResolverTypeWrapper<T> = Promise<T> | T;


export type LegacyStitchingResolver<TResult, TParent, TContext, TArgs> = {
  fragment: string;
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};

export type NewStitchingResolver<TResult, TParent, TContext, TArgs> = {
  selectionSet: string;
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};
export type StitchingResolver<TResult, TParent, TContext, TArgs> = LegacyStitchingResolver<TResult, TParent, TContext, TArgs> | NewStitchingResolver<TResult, TParent, TContext, TArgs>;
export type Resolver<TResult, TParent = {}, TContext = {}, TArgs = {}> =
  | ResolverFn<TResult, TParent, TContext, TArgs>
  | StitchingResolver<TResult, TParent, TContext, TArgs>;

export type ResolverFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => Promise<TResult> | TResult;

export type SubscriptionSubscribeFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => AsyncIterator<TResult> | Promise<AsyncIterator<TResult>>;

export type SubscriptionResolveFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => TResult | Promise<TResult>;

export interface SubscriptionSubscriberObject<TResult, TKey extends string, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<{ [key in TKey]: TResult }, TParent, TContext, TArgs>;
  resolve?: SubscriptionResolveFn<TResult, { [key in TKey]: TResult }, TContext, TArgs>;
}

export interface SubscriptionResolverObject<TResult, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<any, TParent, TContext, TArgs>;
  resolve: SubscriptionResolveFn<TResult, any, TContext, TArgs>;
}

export type SubscriptionObject<TResult, TKey extends string, TParent, TContext, TArgs> =
  | SubscriptionSubscriberObject<TResult, TKey, TParent, TContext, TArgs>
  | SubscriptionResolverObject<TResult, TParent, TContext, TArgs>;

export type SubscriptionResolver<TResult, TKey extends string, TParent = {}, TContext = {}, TArgs = {}> =
  | ((...args: any[]) => SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>)
  | SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>;

export type TypeResolveFn<TTypes, TParent = {}, TContext = {}> = (
  parent: TParent,
  context: TContext,
  info: GraphQLResolveInfo
) => Maybe<TTypes> | Promise<Maybe<TTypes>>;

export type IsTypeOfResolverFn<T = {}, TContext = {}> = (obj: T, context: TContext, info: GraphQLResolveInfo) => boolean | Promise<boolean>;

export type NextResolverFn<T> = () => Promise<T>;

export type DirectiveResolverFn<TResult = {}, TParent = {}, TContext = {}, TArgs = {}> = (
  next: NextResolverFn<TResult>,
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => TResult | Promise<TResult>;

/** Mapping between all available schema types and the resolvers types */
export type ResolversTypes = {
  Account: ResolverTypeWrapper<Account>;
  String: ResolverTypeWrapper<Scalars['String']>;
  ID: ResolverTypeWrapper<Scalars['ID']>;
  Boolean: ResolverTypeWrapper<Scalars['Boolean']>;
  AccountInput: AccountInput;
  Category: ResolverTypeWrapper<Category>;
  Company: ResolverTypeWrapper<Company>;
  DateTime: ResolverTypeWrapper<Scalars['DateTime']>;
  ExtendedBaseEntity: ResolverTypeWrapper<ExtendedBaseEntity>;
  Image: ResolverTypeWrapper<Image>;
  LogInInput: LogInInput;
  LoginResult: LoginResult;
  Mutation: ResolverTypeWrapper<{}>;
  Query: ResolverTypeWrapper<{}>;
  Float: ResolverTypeWrapper<Scalars['Float']>;
  Review: ResolverTypeWrapper<Review>;
  ReviewInput: ReviewInput;
  Int: ResolverTypeWrapper<Scalars['Int']>;
  Subcategory: ResolverTypeWrapper<Subcategory>;
  Treat: ResolverTypeWrapper<Treat>;
  UpdateAccountInput: UpdateAccountInput;
  Upload: ResolverTypeWrapper<Scalars['Upload']>;
};

/** Mapping between all available schema types and the resolvers parents */
export type ResolversParentTypes = {
  Account: Account;
  String: Scalars['String'];
  ID: Scalars['ID'];
  Boolean: Scalars['Boolean'];
  AccountInput: AccountInput;
  Category: Category;
  Company: Company;
  DateTime: Scalars['DateTime'];
  ExtendedBaseEntity: ExtendedBaseEntity;
  Image: Image;
  LogInInput: LogInInput;
  Mutation: {};
  Query: {};
  Float: Scalars['Float'];
  Review: Review;
  ReviewInput: ReviewInput;
  Int: Scalars['Int'];
  Subcategory: Subcategory;
  Treat: Treat;
  UpdateAccountInput: UpdateAccountInput;
  Upload: Scalars['Upload'];
};

export type AccountResolvers<ContextType = any, ParentType extends ResolversParentTypes['Account'] = ResolversParentTypes['Account']> = {
  avatarUri?: Resolver<Maybe<ResolversTypes['String']>, ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  createdTreats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  email?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  firstName?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  isVerified?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  lastName?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  passwordHash?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  reviews?: Resolver<Array<ResolversTypes['Review']>, ParentType, ContextType>;
  role?: Resolver<Maybe<ResolversTypes['String']>, ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  username?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type CategoryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Category'] = ResolversParentTypes['Category']> = {
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  isPublished?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  subcategories?: Resolver<Array<ResolversTypes['Subcategory']>, ParentType, ContextType>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  updatedBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type CompanyResolvers<ContextType = any, ParentType extends ResolversParentTypes['Company'] = ResolversParentTypes['Company']> = {
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  isPublished?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  updatedBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export interface DateTimeScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['DateTime'], any> {
  name: 'DateTime';
}

export type ExtendedBaseEntityResolvers<ContextType = any, ParentType extends ResolversParentTypes['ExtendedBaseEntity'] = ResolversParentTypes['ExtendedBaseEntity']> = {
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  updatedBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type ImageResolvers<ContextType = any, ParentType extends ResolversParentTypes['Image'] = ResolversParentTypes['Image']> = {
  avatarUri?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  filename?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type MutationResolvers<ContextType = any, ParentType extends ResolversParentTypes['Mutation'] = ResolversParentTypes['Mutation']> = {
  createAccount?: Resolver<ResolversTypes['Account'], ParentType, ContextType, RequireFields<MutationCreateAccountArgs, 'account'>>;
  createCategory?: Resolver<ResolversTypes['Category'], ParentType, ContextType, RequireFields<MutationCreateCategoryArgs, 'name'>>;
  createCompany?: Resolver<ResolversTypes['Company'], ParentType, ContextType, RequireFields<MutationCreateCompanyArgs, 'name'>>;
  createReview?: Resolver<ResolversTypes['Review'], ParentType, ContextType, RequireFields<MutationCreateReviewArgs, 'review'>>;
  createSubcategory?: Resolver<ResolversTypes['Subcategory'], ParentType, ContextType, RequireFields<MutationCreateSubcategoryArgs, 'categoryId' | 'name'>>;
  createTreat?: Resolver<ResolversTypes['Treat'], ParentType, ContextType, RequireFields<MutationCreateTreatArgs, 'categoryId' | 'companyId' | 'name' | 'subcategoryId'>>;
  deleteAccount?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  deleteCategory?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationDeleteCategoryArgs, 'id'>>;
  deleteCompany?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationDeleteCompanyArgs, 'id'>>;
  deleteSubategory?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationDeleteSubategoryArgs, 'id'>>;
  resetPassword?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationResetPasswordArgs, 'password' | 'token'>>;
  updateAccount?: Resolver<ResolversTypes['Account'], ParentType, ContextType, RequireFields<MutationUpdateAccountArgs, 'account'>>;
  uploadProfilePicture?: Resolver<ResolversTypes['Image'], ParentType, ContextType, RequireFields<MutationUploadProfilePictureArgs, 'picture'>>;
  verifyAccount?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationVerifyAccountArgs, 'token'>>;
};

export type QueryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Query'] = ResolversParentTypes['Query']> = {
  account?: Resolver<ResolversTypes['Account'], ParentType, ContextType, RequireFields<QueryAccountArgs, 'id'>>;
  accounts?: Resolver<Array<ResolversTypes['Account']>, ParentType, ContextType>;
  categories?: Resolver<Array<ResolversTypes['Category']>, ParentType, ContextType>;
  category?: Resolver<ResolversTypes['Category'], ParentType, ContextType, RequireFields<QueryCategoryArgs, 'id'>>;
  companies?: Resolver<Array<ResolversTypes['Company']>, ParentType, ContextType>;
  company?: Resolver<ResolversTypes['Company'], ParentType, ContextType, RequireFields<QueryCompanyArgs, 'id'>>;
  currentAccount?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  logIn?: Resolver<ResolversTypes['LoginResult'], ParentType, ContextType, RequireFields<QueryLogInArgs, 'account'>>;
  logOut?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  requestAccountVerification?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<QueryRequestAccountVerificationArgs, 'username'>>;
  requestPasswordReset?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<QueryRequestPasswordResetArgs, 'email'>>;
  reviews?: Resolver<Array<ResolversTypes['Review']>, ParentType, ContextType, RequireFields<QueryReviewsArgs, 'offset'>>;
  searchTreats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType, RequireFields<QuerySearchTreatsArgs, 'searchTerm'>>;
  subcategories?: Resolver<Array<ResolversTypes['Subcategory']>, ParentType, ContextType>;
  subcategoriesByCategory?: Resolver<Array<ResolversTypes['Subcategory']>, ParentType, ContextType, RequireFields<QuerySubcategoriesByCategoryArgs, 'categoryId'>>;
  subcategory?: Resolver<ResolversTypes['Subcategory'], ParentType, ContextType, RequireFields<QuerySubcategoryArgs, never>>;
  treat?: Resolver<ResolversTypes['Treat'], ParentType, ContextType, RequireFields<QueryTreatArgs, 'id'>>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
};

export type ReviewResolvers<ContextType = any, ParentType extends ResolversParentTypes['Review'] = ResolversParentTypes['Review']> = {
  author?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  review?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  score?: Resolver<ResolversTypes['Float'], ParentType, ContextType>;
  treat?: Resolver<ResolversTypes['Treat'], ParentType, ContextType>;
  updatedBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type SubcategoryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Subcategory'] = ResolversParentTypes['Subcategory']> = {
  category?: Resolver<ResolversTypes['Category'], ParentType, ContextType>;
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  isPublished?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  updatedBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type TreatResolvers<ContextType = any, ParentType extends ResolversParentTypes['Treat'] = ResolversParentTypes['Treat']> = {
  category?: Resolver<ResolversTypes['Category'], ParentType, ContextType>;
  company?: Resolver<ResolversTypes['Company'], ParentType, ContextType>;
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  reviews?: Resolver<Array<ResolversTypes['Review']>, ParentType, ContextType>;
  subcategory?: Resolver<ResolversTypes['Subcategory'], ParentType, ContextType>;
  updatedBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export interface UploadScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['Upload'], any> {
  name: 'Upload';
}

export type Resolvers<ContextType = any> = {
  Account?: AccountResolvers<ContextType>;
  Category?: CategoryResolvers<ContextType>;
  Company?: CompanyResolvers<ContextType>;
  DateTime?: GraphQLScalarType;
  ExtendedBaseEntity?: ExtendedBaseEntityResolvers<ContextType>;
  Image?: ImageResolvers<ContextType>;
  Mutation?: MutationResolvers<ContextType>;
  Query?: QueryResolvers<ContextType>;
  Review?: ReviewResolvers<ContextType>;
  Subcategory?: SubcategoryResolvers<ContextType>;
  Treat?: TreatResolvers<ContextType>;
  Upload?: GraphQLScalarType;
};


/**
 * @deprecated
 * Use "Resolvers" root object instead. If you wish to get "IResolvers", add "typesPrefix: I" to your config.
 */
export type IResolvers<ContextType = any> = Resolvers<ContextType>;
