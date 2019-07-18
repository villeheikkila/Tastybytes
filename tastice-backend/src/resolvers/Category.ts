import { prismaObjectType } from "nexus-prisma";

export const Category = prismaObjectType({
  name: "Category",
  definition(t) {
    t.prismaFields(["*"]);
  }
});
