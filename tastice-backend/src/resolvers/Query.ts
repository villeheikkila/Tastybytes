import { getUserId } from "../utils";
import { queryType } from "nexus";
import { stringArg, idArg, mutationType } from "nexus";

export const Query = queryType({
  definition(t) {
    t.field("me", {
      type: "User",
      resolve: (parent, args, ctx) => {
        const userId = getUserId(ctx);
        return ctx.prisma.user({ id: userId });
      }
    });

    t.list.field("users", {
      type: "User",
      resolve: (parent, args, ctx) => {
        return ctx.prisma.users();
      }
    });

    t.list.field("products", {
      type: "Product",
      resolve: (parent, args, ctx) => {
        return ctx.prisma.products();
      }
    });

    t.list.field("user", {
      type: "User",
      args: {
        id: idArg()
      },
      resolve: (_, args, ctx) => {
        return ctx.prisma.users({ where: { id: args.id } });
      }
    });

    t.list.field("product", {
      type: "Product",
      args: {
        id: idArg()
      },
      resolve: (_, args, ctx) => {
        return ctx.prisma.products({ where: { id: args.id } });
      }
    });
  }
});
