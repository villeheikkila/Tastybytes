import { prismaObjectType } from "nexus-prisma";

export const SubCategory = prismaObjectType({
  name: "SubCategory",
  definition(t) {
    t.prismaFields(["*"]);
  }
});
