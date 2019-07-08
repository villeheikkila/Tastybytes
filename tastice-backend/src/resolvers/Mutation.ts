import { stringArg, idArg, mutationType } from 'nexus'
import { hash, compare } from 'bcrypt'
import { sign } from 'jsonwebtoken'
import { prisma } from '../generated/prisma-client'
import { SECRET } from '../utils'

export const Mutation = mutationType({
    definition(t) {
        t.field('signup', {
            type: 'AuthPayload',
            args: {
                name: stringArg({ nullable: true }),
                email: stringArg(),
                password: stringArg(),
            },
            resolve: async (parent, { name, email, password }, ctx) => {
                const hashedPassword = await hash(password, 10)
                const user = await ctx.prisma.createUser({
                    name,
                    email,
                    password: hashedPassword,
                })
                return {
                    token: sign({ userId: user.id }, SECRET),
                    user,
                }
            },
        })

        t.field('login', {
            type: 'AuthPayload',
            args: {
                email: stringArg(),
                password: stringArg(),
            },
            resolve: async (parent, { email, password }, context) => {
                const user = await context.prisma.user({ email })
                if (!user) {
                    throw new Error(`No user found for email: ${email}`)
                }
                const passwordValid = await compare(password, user.password)
                if (!passwordValid) {
                    throw new Error('Invalid password')
                }
                return {
                    token: sign({ userId: user.id }, SECRET),
                    user,
                }
            },
        })

        t.field('addProduct', {
            type: 'Product',
            args: {
                name: stringArg(),
                producer: stringArg(),
                type: stringArg()
            },
            resolve: async (_, args) => {
                return await prisma.createProduct({
                    name: args.name,
                    producer: args.name,
                    type: args.type
                })
            },
        })

        t.field('deleteProduct', {
            type: 'Product',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteProduct({ id })
            },
        })

        t.field('deleteUser', {
            type: 'User',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteUser({ id })
            },
        })
    }
})