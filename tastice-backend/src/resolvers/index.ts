import { Query } from "./Query";
import { User } from "./User";
import { Checkin } from "./Checkin";
import { Company } from "./Company";
import { Product } from "./Product";
import { Category } from "./Category";
import { SubCategory } from "./SubCategory";
import { Mutation } from "./Mutation";
import { AuthPayload } from "./AuthPayload";
import { ProductSubscription, UserSubscription } from "./Subscription";

export const resolvers = {
  Query,
  User,
  Mutation,
  Product,
  Checkin,
  AuthPayload,
  ProductSubscription,
  UserSubscription,
  Category,
  SubCategory
};
