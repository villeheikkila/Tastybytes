import { verify } from 'jsonwebtoken';
import { Context, Token } from '../types';
require('dotenv').config();

export const SECRET: string = process.env.SECRET;

export const getUserId = (context: Context): string => {
    const Authorization = context.request.get('Authorization');
    if (Authorization) {
        const token = Authorization.replace('Bearer ', '');
        const verifiedToken = verify(token, SECRET) as Token;
        return verifiedToken && verifiedToken.userId;
    }
};
