import { idArg, queryType, stringArg } from 'nexus';
import { getUserId } from '../../utils';

export const Query = queryType({
    definition(t) {
        t.field('me', {
            type: 'User',
            resolve: (parent, args, ctx) => {
                const userId = getUserId(ctx);
                return ctx.prisma.user({ id: userId });
            },
        });

        t.list.field('users', {
            type: 'User',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.users({ orderBy: 'createdAt_DESC' });
            },
        });

        t.list.field('products', {
            type: 'Product',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.products({ orderBy: 'createdAt_DESC' });
            },
        });

        t.list.field('friendRequests', {
            type: 'FriendRequest',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.friendRequests();
            },
        });

        t.list.field('friendRequest', {
            type: 'FriendRequest',
            args: {
                id: idArg(),
            },
            resolve: (parent, { id }, ctx) => {
                return ctx.prisma.friendRequests({
                    where: {
                        OR: [{ receiver_some: { id } }, { sender_some: { id } }],
                    },
                });
            },
        });

        t.list.field('categories', {
            type: 'Category',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.categories();
            },
        });

        t.list.field('subCategories', {
            type: 'SubCategory',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.subCategories();
            },
        });

        t.list.field('checkins', {
            type: 'Checkin',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.checkins({ orderBy: 'createdAt_DESC' });
            },
        });

        t.list.field('user', {
            type: 'User',
            args: {
                id: idArg(),
            },
            resolve: (_, args, ctx) => {
                return ctx.prisma.users({ where: { id: args.id } });
            },
        });

        t.list.field('checkin', {
            type: 'Checkin',
            args: {
                id: idArg(),
            },
            resolve: (_, args, ctx) => {
                return ctx.prisma.checkins({
                    where: { id: args.id },
                });
            },
        });

        t.list.field('company', {
            type: 'Company',
            args: {
                id: idArg(),
            },
            resolve: (_, args, ctx) => {
                return ctx.prisma.companies({
                    where: { id: args.id },
                });
            },
        });

        t.list.field('companies', {
            type: 'Company',
            resolve: (parent, args, ctx) => {
                return ctx.prisma.companies();
            },
        });

        t.list.field('product', {
            type: 'Product',
            args: {
                id: idArg(),
            },
            resolve: (_, { id }, ctx) => {
                return ctx.prisma.products({
                    where: { id },
                    orderBy: 'createdAt_DESC',
                });
            },
        });

        t.list.field('searchProducts', {
            type: 'Product',
            args: {
                filter: stringArg(),
            },
            resolve: (_, { filter }, ctx) => {
                if (!filter) ctx.prisma.products({ orderBy: 'createdAt_DESC' });
                return ctx.prisma.products({
                    where: {
                        OR: [
                            { name_contains: filter },
                            { name_contains: filter.toLowerCase() },
                            { name_contains: filter.toUpperCase() },
                            { name_contains: filter.charAt(0).toUpperCase() + filter.slice(1).toLowerCase() },
                        ],
                    },
                    orderBy: 'createdAt_DESC',
                });
            },
        });

        t.list.field('searchCheckins', {
            type: 'Checkin',
            args: {
                filter: stringArg(),
            },
            resolve: (_, { filter }, ctx) => {
                return ctx.prisma.checkins({
                    where: {
                        OR: [
                            { product: { name_contains: filter } },
                            { product: { name_contains: filter.toLowerCase() } },
                            { product: { name_contains: filter.toUpperCase() } },
                            {
                                product: {
                                    name_contains: filter.charAt(0).toUpperCase() + filter.slice(1).toLowerCase(),
                                },
                            },
                        ],
                    },
                    orderBy: 'createdAt_DESC',
                });
            },
        });

        t.list.field('searchUsers', {
            type: 'User',
            args: {
                filter: stringArg(),
            },
            resolve: (_, { filter }, ctx) => {
                if (!filter) ctx.prisma.products({ orderBy: 'createdAt_DESC' });
                return ctx.prisma.users({
                    where: {
                        OR: [
                            { firstName_contains: filter },
                            { firstName_contains: filter.toLowerCase() },
                            { firstName_contains: filter.toUpperCase() },
                            { firstName_contains: filter.charAt(0).toUpperCase() + filter.slice(1).toLowerCase() },
                            { lastName_contains: filter },
                            { lastName_contains: filter.toLowerCase() },
                            { lastName_contains: filter.toUpperCase() },
                            { lastName_contains: filter.charAt(0).toUpperCase() + filter.slice(1).toLowerCase() },
                        ],
                    },
                });
            },
        });
    },
});
