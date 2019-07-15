import { prismaObjectType } from "nexus-prisma";

export const Checkin = prismaObjectType({
  name: "Checkin",
  definition(t) {
    t.prismaFields(["*"]);
  }
});
