export type Maybe<T> = T;
export type Exact<T extends { [key: string]: unknown }> = {
  [K in keyof T]: T[K];
};
export type MakeOptional<T, K extends keyof T> = Omit<T, K> &
  { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> &
  { [SubKey in K]: Maybe<T[SubKey]> };
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
  __typename?: "Account";
  avatarUri: Maybe<Scalars["String"]>;
  createdDate: Scalars["DateTime"];
  createdTreats: Array<Treat>;
  email: Scalars["String"];
  firstName: Scalars["String"];
  id: Scalars["ID"];
  isVerified: Scalars["Boolean"];
  lastName: Scalars["String"];
  reviews: Array<Review>;
  role: Maybe<Scalars["String"]>;
  updatedDate: Scalars["DateTime"];
  username: Scalars["String"];
};

export type AccountInput = {
  captchaToken: Scalars["String"];
  email: Scalars["String"];
  firstName: Maybe<Scalars["String"]>;
  lastName: Maybe<Scalars["String"]>;
  password: Scalars["String"];
  username: Scalars["String"];
};

export type Category = {
  __typename?: "Category";
  createdBy: Account;
  createdDate: Scalars["DateTime"];
  id: Scalars["ID"];
  isPublished: Scalars["Boolean"];
  name: Scalars["String"];
  subcategories: Array<Subcategory>;
  treats: Array<Treat>;
  updatedBy: Account;
  updatedDate: Scalars["DateTime"];
};

export type Company = {
  __typename?: "Company";
  createdBy: Account;
  createdDate: Scalars["DateTime"];
  id: Scalars["ID"];
  isPublished: Scalars["Boolean"];
  name: Scalars["String"];
  treats: Array<Treat>;
  updatedBy: Account;
  updatedDate: Scalars["DateTime"];
};

export type Config = {
  __typename?: "Config";
  isLocal: Scalars["Boolean"];
  isProd: Scalars["Boolean"];
  recaptchaSiteKey: Scalars["String"];
};

export type ExtendedBaseEntity = {
  __typename?: "ExtendedBaseEntity";
  createdBy: Account;
  createdDate: Scalars["DateTime"];
  id: Scalars["ID"];
  updatedBy: Account;
  updatedDate: Scalars["DateTime"];
};

export type Image = {
  __typename?: "Image";
  avatarUri: Scalars["String"];
  filename: Scalars["String"];
};

export type LogInInput = {
  password: Scalars["String"];
  username: Scalars["String"];
};

/** Return values for the login query. */
export enum LoginResult {
  IncorrectPassword = "INCORRECT_PASSWORD",
  InexistentAccount = "INEXISTENT_ACCOUNT",
  Success = "SUCCESS",
  UnverifiedAccount = "UNVERIFIED_ACCOUNT",
}

export type Mutation = {
  __typename?: "Mutation";
  createAccount: Account;
  createCategory: Category;
  createCompany: Company;
  createReview: Review;
  createSubcategory: Subcategory;
  createTreat: Treat;
  deleteAccount: Scalars["Boolean"];
  deleteCategory: Scalars["Boolean"];
  deleteCompany: Scalars["Boolean"];
  deleteSubategory: Scalars["Boolean"];
  resetPassword: Scalars["Boolean"];
  updateAccount: Account;
  uploadProfilePicture: Image;
  verifyAccount: Scalars["Boolean"];
};

export type MutationCreateAccountArgs = {
  account: AccountInput;
};

export type MutationCreateCategoryArgs = {
  name: Scalars["String"];
};

export type MutationCreateCompanyArgs = {
  name: Scalars["String"];
};

export type MutationCreateReviewArgs = {
  review: ReviewInput;
};

export type MutationCreateSubcategoryArgs = {
  categoryId: Scalars["ID"];
  name: Scalars["String"];
};

export type MutationCreateTreatArgs = {
  categoryId: Scalars["ID"];
  companyId: Scalars["ID"];
  name: Scalars["String"];
  subcategoryId: Scalars["ID"];
};

export type MutationDeleteCategoryArgs = {
  id: Scalars["ID"];
};

export type MutationDeleteCompanyArgs = {
  id: Scalars["ID"];
};

export type MutationDeleteSubategoryArgs = {
  id: Scalars["ID"];
};

export type MutationResetPasswordArgs = {
  password: Scalars["String"];
  token: Scalars["String"];
};

export type MutationUpdateAccountArgs = {
  account: UpdateAccountInput;
};

export type MutationUploadProfilePictureArgs = {
  picture: Scalars["Upload"];
};

export type MutationVerifyAccountArgs = {
  token: Scalars["String"];
};

export type Query = {
  __typename?: "Query";
  account: Account;
  accounts: Array<Account>;
  categories: Array<Category>;
  category: Category;
  companies: Array<Company>;
  company: Company;
  configs: Config;
  currentAccount: Account;
  logIn: LoginResult;
  logOut: Scalars["Boolean"];
  requestAccountVerification: Scalars["Boolean"];
  requestPasswordReset: Scalars["Boolean"];
  reviews: Array<Review>;
  searchTreats: Array<Treat>;
  subcategories: Array<Subcategory>;
  subcategoriesByCategory: Array<Subcategory>;
  subcategory: Subcategory;
  treat: Treat;
  treats: Array<Treat>;
};

export type QueryAccountArgs = {
  id: Scalars["ID"];
};

export type QueryCategoryArgs = {
  id: Scalars["ID"];
};

export type QueryCompanyArgs = {
  id: Scalars["ID"];
};

export type QueryLogInArgs = {
  account: LogInInput;
};

export type QueryRequestAccountVerificationArgs = {
  username: Scalars["String"];
};

export type QueryRequestPasswordResetArgs = {
  email: Scalars["String"];
};

export type QueryReviewsArgs = {
  offset: Scalars["Float"];
};

export type QuerySearchTreatsArgs = {
  offset: Scalars["Float"];
  searchTerm: Scalars["String"];
};

export type QuerySubcategoriesByCategoryArgs = {
  categoryId: Scalars["ID"];
};

export type QuerySubcategoryArgs = {
  id: Maybe<Scalars["ID"]>;
};

export type QueryTreatArgs = {
  id: Scalars["ID"];
};

export type Review = {
  __typename?: "Review";
  author: Account;
  createdBy: Account;
  createdDate: Scalars["DateTime"];
  id: Scalars["ID"];
  review: Scalars["String"];
  score: Scalars["Float"];
  treat: Treat;
  updatedBy: Account;
  updatedDate: Scalars["DateTime"];
};

export type ReviewInput = {
  review: Maybe<Scalars["String"]>;
  score: Scalars["Int"];
  treatId: Scalars["ID"];
};

export type Subcategory = {
  __typename?: "Subcategory";
  category: Category;
  createdBy: Account;
  createdDate: Scalars["DateTime"];
  id: Scalars["ID"];
  isPublished: Scalars["Boolean"];
  name: Scalars["String"];
  treats: Array<Treat>;
  updatedBy: Account;
  updatedDate: Scalars["DateTime"];
};

export type Treat = {
  __typename?: "Treat";
  category: Category;
  company: Company;
  createdBy: Account;
  createdDate: Scalars["DateTime"];
  id: Scalars["ID"];
  name: Scalars["String"];
  reviews: Array<Review>;
  subcategory: Subcategory;
  updatedBy: Account;
  updatedDate: Scalars["DateTime"];
};

export type UpdateAccountInput = {
  email: Maybe<Scalars["String"]>;
  firstName: Maybe<Scalars["String"]>;
  lastName: Maybe<Scalars["String"]>;
  password: Maybe<Scalars["String"]>;
  username: Maybe<Scalars["String"]>;
};
