import { allow, rule, shield } from 'graphql-shield';
import { prisma } from '../generated/prisma-client';
import { getUserId } from '../utils';

const rules = {
    isAuthenticatedUser: rule()(async (parent, args, context) => {
        const id = getUserId(context);
        return await prisma.$exists.user({ id });
    }),
    isOwnUser: rule()(async (parent, { id }, context) => {
        const userId = getUserId(context);
        const user = await context.prisma.user({ id }).id();
        return userId === user.id;
    }),
};

export const permissions = shield({
    Query: {
        '*': rules.isAuthenticatedUser,
    },
    Mutation: {
        '*': rules.isAuthenticatedUser,
        login: allow,
        signup: allow,
    },
});
