import { idArg, subscriptionField } from 'nexus';

export const ProductSubscription = subscriptionField('product', {
    type: 'ProductSubscriptionPayload',
    subscribe(root, args, ctx) {
        return ctx.prisma.$subscribe.product() as any;
    },
    resolve(payload) {
        return payload;
    },
});

export const UserSubscription = subscriptionField('user', {
    type: 'UserSubscriptionPayload',
    subscribe(root, args, ctx) {
        return ctx.prisma.$subscribe.user() as any;
    },
    resolve(payload) {
        return payload;
    },
});

export const FriendRequestSubscription = subscriptionField('friendRequest', {
    type: 'FriendRequestSubscriptionPayload',
    args: {
        id: idArg(),
    },
    subscribe(root, { id }, ctx) {
        return ctx.prisma.$subscribe.friendRequest({
            where: {
                receiver_every: { id_contains: id },
            },
        }) as any;
    },
    resolve(payload) {
        return payload;
    },
});
