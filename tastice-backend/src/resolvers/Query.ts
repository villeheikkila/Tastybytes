
import { getUserId } from '../utils'
import { stringArg, idArg, queryType } from 'nexus'
import { prisma } from '../../generated/prisma-client'

export const Query = queryType({
    definition(t) {
        t.field('me', {
            type: 'User',
            resolve: (parent, args, ctx) => {
                const userId = getUserId(ctx)
                return ctx.prisma.user({ id: userId })
            },
        })


    }

})