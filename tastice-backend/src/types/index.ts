import { Prisma } from '../generated/prisma-client';

export interface Context {
    prisma: Prisma;
    request: any;
}

export interface Token {
    userId: string;
}
