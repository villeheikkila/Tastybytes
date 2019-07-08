import { verify } from 'jsonwebtoken'
import { Context, Token } from '../types'
require('dotenv').config()

export const SECRET: string = process.env.SECRET

export function getUserId(context: Context) {
    const Authorization = context.request.get('Authorization')
    if (Authorization) {
        const token = Authorization.replace('Bearer ', '')
        const verifiedToken = verify(token, SECRET) as Token
        return verifiedToken && verifiedToken.userId
    }
}