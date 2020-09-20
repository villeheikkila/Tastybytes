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
  id: Scalars['ID'];
  username: Scalars['String'];
  firstName: Scalars['String'];
  lastName: Scalars['String'];
  email: Scalars['String'];
  avatarUri?: Maybe<Scalars['String']>;
  passwordHash: Scalars['String'];
  isVerified: Scalars['Boolean'];
  reviews: Array<Review>;
  createdTreats: Array<Treat>;
};

export type AccountInput = {
  username: Scalars['String'];
  email: Scalars['String'];
  password: Scalars['String'];
  captchaToken: Scalars['String'];
  firstName?: Maybe<Scalars['String']>;
  lastName?: Maybe<Scalars['String']>;
};

export type Category = {
  __typename?: 'Category';
  id: Scalars['ID'];
  name: Scalars['String'];
  isPublished: Scalars['Boolean'];
  treats: Array<Treat>;
  subcategories: Array<Subcategory>;
  createdDate: Scalars['DateTime'];
  updatedDate: Scalars['DateTime'];
};

export type Company = {
  __typename?: 'Company';
  id: Scalars['ID'];
  name: Scalars['String'];
  isPublished: Scalars['Boolean'];
  treats: Array<Treat>;
  createdBy: Account;
  createdDate: Scalars['DateTime'];
  updatedDate: Scalars['DateTime'];
};


export type Image = {
  __typename?: 'Image';
  filename: Scalars['String'];
  avatarUri: Scalars['String'];
};

export type LogInInput = {
  username: Scalars['String'];
  password: Scalars['String'];
};

/** Return values for the login query. */
export enum LoginResult {
  Success = 'SUCCESS',
  InexistentAccount = 'INEXISTENT_ACCOUNT',
  UnverifiedAccount = 'UNVERIFIED_ACCOUNT',
  IncorrectPassword = 'INCORRECT_PASSWORD'
}

export type Mutation = {
  __typename?: 'Mutation';
  createAccount: Account;
  updateAccount: Account;
  deleteAccount: Scalars['Boolean'];
  resetPassword: Scalars['Boolean'];
  verifyAccount: Scalars['Boolean'];
  uploadProfilePicture: Image;
  createCategory: Category;
  deleteCategory: Scalars['Boolean'];
  createCompany: Company;
  deleteCompany: Scalars['Boolean'];
  createReview: Review;
  createSubcategory: Subcategory;
  deleteSubategory: Scalars['Boolean'];
  createTreat: Treat;
};


export type MutationCreateAccountArgs = {
  account: AccountInput;
};


export type MutationUpdateAccountArgs = {
  account: UpdateAccountInput;
};


export type MutationResetPasswordArgs = {
  password: Scalars['String'];
  token: Scalars['String'];
};


export type MutationVerifyAccountArgs = {
  token: Scalars['String'];
};


export type MutationUploadProfilePictureArgs = {
  picture: Scalars['Upload'];
};


export type MutationCreateCategoryArgs = {
  name: Scalars['String'];
};


export type MutationDeleteCategoryArgs = {
  id: Scalars['ID'];
};


export type MutationCreateCompanyArgs = {
  name: Scalars['String'];
};


export type MutationDeleteCompanyArgs = {
  id: Scalars['ID'];
};


export type MutationCreateReviewArgs = {
  review: ReviewInput;
};


export type MutationCreateSubcategoryArgs = {
  categoryId: Scalars['ID'];
  name: Scalars['String'];
};


export type MutationDeleteSubategoryArgs = {
  id: Scalars['ID'];
};


export type MutationCreateTreatArgs = {
  subcategoryId: Scalars['ID'];
  categoryId: Scalars['ID'];
  companyId: Scalars['ID'];
  name: Scalars['String'];
};

export type Query = {
  __typename?: 'Query';
  accounts: Array<Account>;
  account: Account;
  requestAccountVerification: Scalars['Boolean'];
  logIn: LoginResult;
  logOut: Scalars['Boolean'];
  currentAccount: Account;
  requestPasswordReset: Scalars['Boolean'];
  categories: Array<Category>;
  category: Category;
  companies: Array<Company>;
  company: Company;
  reviews: Array<Review>;
  subcategories: Array<Subcategory>;
  subcategory: Subcategory;
  subcategoriesByCategory: Array<Subcategory>;
  treats: Array<Treat>;
  treat: Treat;
  searchTreats: Array<Treat>;
};


export type QueryAccountArgs = {
  id: Scalars['ID'];
};


export type QueryRequestAccountVerificationArgs = {
  username: Scalars['String'];
};


export type QueryLogInArgs = {
  account: LogInInput;
};


export type QueryRequestPasswordResetArgs = {
  email: Scalars['String'];
};


export type QueryCategoryArgs = {
  id: Scalars['ID'];
};


export type QueryCompanyArgs = {
  id: Scalars['ID'];
};


export type QueryReviewsArgs = {
  offset: Scalars['Float'];
};


export type QuerySubcategoryArgs = {
  id?: Maybe<Scalars['ID']>;
};


export type QuerySubcategoriesByCategoryArgs = {
  categoryId: Scalars['ID'];
};


export type QueryTreatArgs = {
  id: Scalars['ID'];
};


export type QuerySearchTreatsArgs = {
  offset?: Maybe<Scalars['Float']>;
  searchTerm: Scalars['String'];
};

export type Review = {
  __typename?: 'Review';
  id: Scalars['ID'];
  score: Scalars['Float'];
  review: Scalars['String'];
  treat: Treat;
  author: Account;
  createdDate: Scalars['DateTime'];
  updatedDate: Scalars['DateTime'];
};

export type ReviewInput = {
  treatId: Scalars['ID'];
  score: Scalars['Int'];
  review?: Maybe<Scalars['String']>;
};

export type Subcategory = {
  __typename?: 'Subcategory';
  id: Scalars['ID'];
  name: Scalars['String'];
  isPublished: Scalars['Boolean'];
  treats: Array<Treat>;
  category: Category;
  createdDate: Scalars['DateTime'];
  updatedDate: Scalars['DateTime'];
};

export type Treat = {
  __typename?: 'Treat';
  id: Scalars['ID'];
  name: Scalars['String'];
  reviews: Array<Review>;
  createdBy: Account;
  company: Company;
  category: Category;
  subcategory: Subcategory;
  createdDate: Scalars['DateTime'];
  updatedDate: Scalars['DateTime'];
};

export type UpdateAccountInput = {
  username?: Maybe<Scalars['String']>;
  email?: Maybe<Scalars['String']>;
  password?: Maybe<Scalars['String']>;
  firstName?: Maybe<Scalars['String']>;
  lastName?: Maybe<Scalars['String']>;
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

export type IsTypeOfResolverFn<T = {}> = (obj: T, info: GraphQLResolveInfo) => boolean | Promise<boolean>;

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
  Query: ResolverTypeWrapper<{}>;
  Account: ResolverTypeWrapper<Account>;
  ID: ResolverTypeWrapper<Scalars['ID']>;
  String: ResolverTypeWrapper<Scalars['String']>;
  Boolean: ResolverTypeWrapper<Scalars['Boolean']>;
  Review: ResolverTypeWrapper<Review>;
  Float: ResolverTypeWrapper<Scalars['Float']>;
  Treat: ResolverTypeWrapper<Treat>;
  Company: ResolverTypeWrapper<Company>;
  DateTime: ResolverTypeWrapper<Scalars['DateTime']>;
  Category: ResolverTypeWrapper<Category>;
  Subcategory: ResolverTypeWrapper<Subcategory>;
  LogInInput: LogInInput;
  LoginResult: LoginResult;
  Mutation: ResolverTypeWrapper<{}>;
  AccountInput: AccountInput;
  UpdateAccountInput: UpdateAccountInput;
  Upload: ResolverTypeWrapper<Scalars['Upload']>;
  Image: ResolverTypeWrapper<Image>;
  ReviewInput: ReviewInput;
  Int: ResolverTypeWrapper<Scalars['Int']>;
};

/** Mapping between all available schema types and the resolvers parents */
export type ResolversParentTypes = {
  Query: {};
  Account: Account;
  ID: Scalars['ID'];
  String: Scalars['String'];
  Boolean: Scalars['Boolean'];
  Review: Review;
  Float: Scalars['Float'];
  Treat: Treat;
  Company: Company;
  DateTime: Scalars['DateTime'];
  Category: Category;
  Subcategory: Subcategory;
  LogInInput: LogInInput;
  Mutation: {};
  AccountInput: AccountInput;
  UpdateAccountInput: UpdateAccountInput;
  Upload: Scalars['Upload'];
  Image: Image;
  ReviewInput: ReviewInput;
  Int: Scalars['Int'];
};

export type AccountResolvers<ContextType = any, ParentType extends ResolversParentTypes['Account'] = ResolversParentTypes['Account']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  username?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  firstName?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  lastName?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  email?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  avatarUri?: Resolver<Maybe<ResolversTypes['String']>, ParentType, ContextType>;
  passwordHash?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  isVerified?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  reviews?: Resolver<Array<ResolversTypes['Review']>, ParentType, ContextType>;
  createdTreats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export type CategoryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Category'] = ResolversParentTypes['Category']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  isPublished?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  subcategories?: Resolver<Array<ResolversTypes['Subcategory']>, ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export type CompanyResolvers<ContextType = any, ParentType extends ResolversParentTypes['Company'] = ResolversParentTypes['Company']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  isPublished?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export interface DateTimeScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['DateTime'], any> {
  name: 'DateTime';
}

export type ImageResolvers<ContextType = any, ParentType extends ResolversParentTypes['Image'] = ResolversParentTypes['Image']> = {
  filename?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  avatarUri?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export type MutationResolvers<ContextType = any, ParentType extends ResolversParentTypes['Mutation'] = ResolversParentTypes['Mutation']> = {
  createAccount?: Resolver<ResolversTypes['Account'], ParentType, ContextType, RequireFields<MutationCreateAccountArgs, 'account'>>;
  updateAccount?: Resolver<ResolversTypes['Account'], ParentType, ContextType, RequireFields<MutationUpdateAccountArgs, 'account'>>;
  deleteAccount?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  resetPassword?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationResetPasswordArgs, 'password' | 'token'>>;
  verifyAccount?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationVerifyAccountArgs, 'token'>>;
  uploadProfilePicture?: Resolver<ResolversTypes['Image'], ParentType, ContextType, RequireFields<MutationUploadProfilePictureArgs, 'picture'>>;
  createCategory?: Resolver<ResolversTypes['Category'], ParentType, ContextType, RequireFields<MutationCreateCategoryArgs, 'name'>>;
  deleteCategory?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationDeleteCategoryArgs, 'id'>>;
  createCompany?: Resolver<ResolversTypes['Company'], ParentType, ContextType, RequireFields<MutationCreateCompanyArgs, 'name'>>;
  deleteCompany?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationDeleteCompanyArgs, 'id'>>;
  createReview?: Resolver<ResolversTypes['Review'], ParentType, ContextType, RequireFields<MutationCreateReviewArgs, 'review'>>;
  createSubcategory?: Resolver<ResolversTypes['Subcategory'], ParentType, ContextType, RequireFields<MutationCreateSubcategoryArgs, 'categoryId' | 'name'>>;
  deleteSubategory?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<MutationDeleteSubategoryArgs, 'id'>>;
  createTreat?: Resolver<ResolversTypes['Treat'], ParentType, ContextType, RequireFields<MutationCreateTreatArgs, 'subcategoryId' | 'categoryId' | 'companyId' | 'name'>>;
};

export type QueryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Query'] = ResolversParentTypes['Query']> = {
  accounts?: Resolver<Array<ResolversTypes['Account']>, ParentType, ContextType>;
  account?: Resolver<ResolversTypes['Account'], ParentType, ContextType, RequireFields<QueryAccountArgs, 'id'>>;
  requestAccountVerification?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<QueryRequestAccountVerificationArgs, 'username'>>;
  logIn?: Resolver<ResolversTypes['LoginResult'], ParentType, ContextType, RequireFields<QueryLogInArgs, 'account'>>;
  logOut?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  currentAccount?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  requestPasswordReset?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType, RequireFields<QueryRequestPasswordResetArgs, 'email'>>;
  categories?: Resolver<Array<ResolversTypes['Category']>, ParentType, ContextType>;
  category?: Resolver<ResolversTypes['Category'], ParentType, ContextType, RequireFields<QueryCategoryArgs, 'id'>>;
  companies?: Resolver<Array<ResolversTypes['Company']>, ParentType, ContextType>;
  company?: Resolver<ResolversTypes['Company'], ParentType, ContextType, RequireFields<QueryCompanyArgs, 'id'>>;
  reviews?: Resolver<Array<ResolversTypes['Review']>, ParentType, ContextType, RequireFields<QueryReviewsArgs, 'offset'>>;
  subcategories?: Resolver<Array<ResolversTypes['Subcategory']>, ParentType, ContextType>;
  subcategory?: Resolver<ResolversTypes['Subcategory'], ParentType, ContextType, RequireFields<QuerySubcategoryArgs, never>>;
  subcategoriesByCategory?: Resolver<Array<ResolversTypes['Subcategory']>, ParentType, ContextType, RequireFields<QuerySubcategoriesByCategoryArgs, 'categoryId'>>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  treat?: Resolver<ResolversTypes['Treat'], ParentType, ContextType, RequireFields<QueryTreatArgs, 'id'>>;
  searchTreats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType, RequireFields<QuerySearchTreatsArgs, 'searchTerm'>>;
};

export type ReviewResolvers<ContextType = any, ParentType extends ResolversParentTypes['Review'] = ResolversParentTypes['Review']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  score?: Resolver<ResolversTypes['Float'], ParentType, ContextType>;
  review?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  treat?: Resolver<ResolversTypes['Treat'], ParentType, ContextType>;
  author?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export type SubcategoryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Subcategory'] = ResolversParentTypes['Subcategory']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  isPublished?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  treats?: Resolver<Array<ResolversTypes['Treat']>, ParentType, ContextType>;
  category?: Resolver<ResolversTypes['Category'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export type TreatResolvers<ContextType = any, ParentType extends ResolversParentTypes['Treat'] = ResolversParentTypes['Treat']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  reviews?: Resolver<Array<ResolversTypes['Review']>, ParentType, ContextType>;
  createdBy?: Resolver<ResolversTypes['Account'], ParentType, ContextType>;
  company?: Resolver<ResolversTypes['Company'], ParentType, ContextType>;
  category?: Resolver<ResolversTypes['Category'], ParentType, ContextType>;
  subcategory?: Resolver<ResolversTypes['Subcategory'], ParentType, ContextType>;
  createdDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  updatedDate?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType>;
};

export interface UploadScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['Upload'], any> {
  name: 'Upload';
}

export type Resolvers<ContextType = any> = {
  Account?: AccountResolvers<ContextType>;
  Category?: CategoryResolvers<ContextType>;
  Company?: CompanyResolvers<ContextType>;
  DateTime?: GraphQLScalarType;
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
