import { prisma } from '../generated/prisma-client'
import { prismaObjectType } from 'nexus-prisma'


export const Product = prismaObjectType({
    name: 'Product',
    definition(t) {
        t.prismaFields(['*'])
    },
})