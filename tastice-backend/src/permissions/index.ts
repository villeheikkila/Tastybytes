
import { rule, shield } from 'graphql-shield'
import { getUserId } from '../utils'

const rules = {
    isAuthenticatedUser: rule()((parent, args, context) => {
        const userId = getUserId(context)
        return Boolean(userId)
    }),
    isOwnUser: rule()(async (parent, { id }, context) => {
        const userId = getUserId(context)
        const user = await context.prisma.user({ id }).id()
        return userId === user.id
    }),
}

export const permissions = shield({
    Query: {
        me: rules.isAuthenticatedUser,
        //products: rules.isAuthenticatedUser,
    },
})