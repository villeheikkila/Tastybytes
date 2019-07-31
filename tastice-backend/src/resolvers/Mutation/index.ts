import { compare, hash } from 'bcrypt';
import { sign } from 'jsonwebtoken';
import { idArg, intArg, mutationType, stringArg } from 'nexus';
import { prisma } from '../../generated/prisma-client';
import { SECRET } from '../../utils';
import { createIfNewCompany, createIfNewSubCategories } from './utils';

export const Mutation = mutationType({
    definition(t) {
        t.field('signup', {
            type: 'AuthPayload',
            args: {
                firstName: stringArg(),
                lastName: stringArg(),
                email: stringArg(),
                password: stringArg(),
            },
            resolve: async (parent, { firstName, lastName, email, password }, ctx) => {
                const hashedPassword = await hash(password, 10);
                const user = await ctx.prisma.createUser({
                    firstName,
                    lastName,
                    email,
                    password: hashedPassword,
                    admin: false,
                });
                return {
                    token: sign({ userId: user.id }, SECRET),
                    user,
                };
            },
        });

        t.field('login', {
            type: 'AuthPayload',
            args: {
                email: stringArg(),
                password: stringArg(),
            },
            resolve: async (parent, { email, password }, context) => {
                const user = await context.prisma.user({ email });
                if (!user) {
                    throw new Error(`No user found for email: ${email}`);
                }
                const passwordValid = await compare(password, user.password);
                if (!passwordValid) {
                    throw new Error('Invalid password');
                }
                return {
                    token: sign({ userId: user.id }, SECRET),
                    user,
                };
            },
        });

        t.field('addProduct', {
            type: 'Product',
            args: {
                name: stringArg(),
                company: stringArg(),
                categoryId: idArg({ nullable: true }),
                subCategories: stringArg({ list: true }),
            },
            resolve: async (_, { name, company, categoryId, subCategories }) => {
                const subCategoryIds = await createIfNewSubCategories(subCategories, categoryId);
                const companyId = await createIfNewCompany(company);
                return await prisma.createProduct({
                    name: name.charAt(0).toUpperCase() + name.slice(1).toLowerCase(),
                    company: { connect: { id: companyId } },
                    category: { connect: { id: categoryId } },
                    subCategory: { connect: subCategoryIds },
                });
            },
        });

        t.field('updateProduct', {
            type: 'Product',
            args: {
                id: idArg(),
                name: stringArg(),
                company: stringArg(),
                categoryId: idArg({ nullable: true }),
                subCategories: stringArg({ list: true }),
            },
            resolve: async (_, { id, name, company, categoryId, subCategories }) => {
                const subCategoryIds = await createIfNewSubCategories(subCategories, categoryId);
                const companyId = await createIfNewCompany(company);

                return await prisma.updateProduct({
                    where: { id },
                    data: {
                        name: name.charAt(0).toUpperCase() + name.slice(1).toLowerCase(),
                        company: { connect: { id: companyId } },
                        category: { connect: { id: categoryId } },
                        subCategory: { connect: subCategoryIds },
                    },
                });
            },
        });

        t.field('updateUser', {
            type: 'User',
            args: {
                id: idArg(),
                firstName: stringArg(),
                lastName: stringArg(),
                email: stringArg(),
            },
            resolve: async (_, { id, firstName, lastName, email }) => {
                return await prisma.updateUser({
                    where: { id },
                    data: {
                        firstName: firstName.charAt(0).toUpperCase() + firstName.slice(1).toLowerCase(),
                        lastName: lastName.charAt(0).toUpperCase() + lastName.slice(1).toLowerCase(),
                        email: email.toLowerCase(),
                    },
                });
            },
        });

        t.field('updateCheckin', {
            type: 'Checkin',
            args: {
                id: idArg(),
                rating: intArg(),
                comment: stringArg(),
            },
            resolve: async (_, { id, rating, comment }) => {
                return await prisma.updateCheckin({
                    where: { id },
                    data: {
                        rating,
                        comment,
                    },
                });
            },
        });

        t.field('deleteProduct', {
            type: 'Product',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteProduct({ id });
            },
        });

        t.field('deleteFriendRequest', {
            type: 'FriendRequest',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteFriendRequest({ id });
            },
        });

        t.field('deleteUser', {
            type: 'User',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteUser({ id });
            },
        });

        t.field('deleteCategory', {
            type: 'Category',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteCategory({ id });
            },
        });

        t.field('deleteCheckin', {
            type: 'Checkin',
            nullable: true,
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.deleteCheckin({ id });
            },
        });

        t.field('deleteFriend', {
            type: 'User',
            args: {
                id: idArg(),
                friendId: idArg(),
            },
            resolve: async (_, { id, friendId }, ctx) => {
                return await prisma.updateUser({
                    where: { id },
                    data: {
                        friends: { disconnect: { id: friendId } },
                    },
                });
            },
        });

        t.field('createCheckin', {
            type: 'Checkin',
            args: {
                authorId: idArg({ nullable: true }),
                productId: idArg({ nullable: true }),
                rating: intArg(),
                comment: stringArg(),
            },
            resolve: (_, { authorId, productId, rating, comment }, ctx) => {
                return ctx.prisma.createCheckin({
                    rating,
                    comment,
                    product: { connect: { id: productId } },
                    author: { connect: { id: authorId } },
                });
            },
        });

        t.field('createFriendRequest', {
            type: 'FriendRequest',
            args: {
                receiverId: idArg({ nullable: true }),
                senderId: idArg({ nullable: true }),
                message: stringArg(),
            },
            resolve: (_, { receiverId, senderId, message }, ctx) => {
                return ctx.prisma.createFriendRequest({
                    receiver: { connect: { id: receiverId } },
                    sender: { connect: { id: senderId } },
                    message,
                });
            },
        });

        t.field('acceptFriendRequest', {
            type: 'User',
            args: {
                id: idArg(),
            },
            resolve: async (_, { id }) => {
                const validFriendRequest = await prisma.$exists.friendRequest({
                    id,
                });

                if (validFriendRequest) {
                    const sender = await prisma.friendRequest({ id }).sender();
                    const senderId = sender[0].id;
                    const receiver = await prisma.friendRequest({ id }).receiver();
                    const receiverId = receiver[0].id;

                    await prisma.deleteFriendRequest({ id });

                    return await prisma.updateUser({
                        where: { id: receiverId },
                        data: {
                            friends: { connect: { id: senderId } },
                        },
                    });
                } else {
                    throw new Error('Invalid friend request');
                }
            },
        });

        t.field('createCategory', {
            type: 'Category',
            args: {
                name: stringArg(),
            },
            resolve: (_, { name }, ctx) => {
                return ctx.prisma.createCategory({
                    name: name.charAt(0).toUpperCase() + name.slice(1).toLowerCase(),
                });
            },
        });

        t.field('createCompany', {
            type: 'Company',
            args: {
                name: stringArg(),
            },
            resolve: (_, { name }, ctx) => {
                return ctx.prisma.createCompany({
                    name: name.charAt(0).toUpperCase() + name.slice(1).toLowerCase(),
                });
            },
        });

        t.field('createSubCategory', {
            type: 'SubCategory',
            args: {
                name: stringArg(),
                categoryId: idArg({ nullable: true }),
            },
            resolve: (_, { name, categoryId }, ctx) => {
                return ctx.prisma.createSubCategory({
                    category: { connect: { id: categoryId } },
                    name: name.charAt(0).toUpperCase() + name.slice(1).toLowerCase(),
                });
            },
        });
    },
});
