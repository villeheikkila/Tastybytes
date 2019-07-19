import { prismaObjectType } from "nexus-prisma";

export const Company = prismaObjectType({
  name: "Company",
  definition(t) {
    t.prismaFields(["*"]);
  }
});
