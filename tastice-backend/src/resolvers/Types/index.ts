import { prismaObjectType } from 'nexus-prisma';
import { objectType } from 'nexus';

export const SubCategory = prismaObjectType({
    name: 'SubCategory',
    definition(t) {
        t.prismaFields(['*']);
    },
});

export const User = prismaObjectType({
    name: 'User',
    definition(t) {
        t.prismaFields(['id', 'firstName', 'lastName', 'email', 'admin', 'checkins']);
    },
});

export const Product = prismaObjectType({
    name: 'Product',
    definition(t) {
        t.prismaFields(['*']);
    },
});

export const Company = prismaObjectType({
    name: 'Company',
    definition(t) {
        t.prismaFields(['*']);
    },
});

export const Category = prismaObjectType({
    name: 'Category',
    definition(t) {
        t.prismaFields(['*']);
    },
});

export const AuthPayload = objectType({
    name: 'AuthPayload',
    definition(t) {
        t.string('token');
        t.field('user', { type: 'User' });
    },
});

export const Checkin = prismaObjectType({
    name: 'Checkin',
    definition(t) {
        t.prismaFields(['*']);
    },
});
