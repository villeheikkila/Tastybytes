import { Query } from "./Query";
import { User } from "./User";
import { Checkin } from "./Checkin";
import { Product } from "./Product";
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
  UserSubscription
};
