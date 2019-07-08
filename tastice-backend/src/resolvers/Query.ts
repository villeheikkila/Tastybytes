
import { getUserId } from '../utils'
import { queryType } from 'nexus'

export const Query = queryType({
    definition(t) {
        t.field('me', {
            type: 'User',
            resolve: (parent, args, ctx) => {
                const userId = getUserId(ctx)
                return ctx.prisma.user({ id: userId })
            },
        })

        t.list.field('users', {
            type: 'User',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.users()
            },
        })


        t.list.field('products', {
            type: 'Product',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.products()
            },
        })


    }
})