import { stringArg, idArg, mutationType } from 'nexus'
import { hash, compare } from 'bcrypt'
require('dotenv').config()
import { sign } from 'jsonwebtoken'
import { prisma } from '../../generated/prisma-client'


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
                    token: sign({ userId: user.id }, process.env.SECRET),
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
                    token: sign({ userId: user.id }, APP_SECRET),
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
    }
})