import { AuthChangeEvent, Provider, Session, User, UserCredentials } from '@supabase/gotrue-js'
import React, { createContext, useCallback, useContext, useEffect, useState } from 'react'
import { useSupabaseClient } from './useSupabase'

export type UseSignInState = {
    error?: any | null
    fetching: boolean
    session?: Session | null
    user?: User | null
}

export type UseSignInResponse = [
    UseSignInState,
    (
        credentials: UserCredentials,
        options?: UseSignInOptions,
    ) => Promise<Pick<UseSignInState, 'error' | 'session' | 'user'>>,
]

export type UseSignInOptions = {
    redirectTo?: string
    scopes?: string
}

export type UseSignInConfig = {
    provider?: Provider
    options?: UseSignInOptions
}

const initialState = {
    count: undefined,
    data: undefined,
    error: undefined,
    fetching: false,
}

export function useSignIn(config: UseSignInConfig = {}): UseSignInResponse {
    const client = useSupabaseClient()
    const [state, setState] = useState<UseSignInState>(initialState)

    const execute = useCallback(
        async (credentials: UserCredentials, options?: UseSignInOptions) => {
            setState({ ...initialState, fetching: true })
            const { error, session, user } = await client.auth.signIn(
                {
                    provider: config.provider,
                    ...credentials,
                },
                options ?? config.options,
            )
            const res = { error, session, user }
            setState({ ...res, fetching: false })
            return res
        },
        [client, config],
    )

    return [state, execute]
}



export type UseSignUpState = {
    error?: any | null
    fetching: boolean
    session?: Session | null
    user?: User | null
}

export type UseSignUpResponse = [
    UseSignUpState,
    (
        credentials: UserCredentials,
        options?: UseSignUpOptions,
    ) => Promise<Pick<UseSignUpState, 'error' | 'session' | 'user'>>,
]

export type UseSignUpOptions = {
    redirectTo?: string
}

export type UseSignUpConfig = {
    options?: UseSignUpOptions
}

export function useSignUp(config: UseSignUpConfig = {}): UseSignUpResponse {
    const client = useSupabaseClient()
    const [state, setState] = useState<UseSignUpState>(initialState)

    const execute = useCallback(
        async (credentials: UserCredentials, options?: UseSignUpOptions) => {
            setState({ ...initialState, fetching: true })
            const { error, session, user } = await client.auth.signUp(
                credentials,
                options ?? config.options,
            )
            const res = { error, session, user }
            setState({ ...res, fetching: false })
            return res
        },
        [client, config],
    )

    return [state, execute]
}



export type UseSignOutState = {
    error?: any | null
    fetching: boolean
}

export type UseSignOutResponse = [
    UseSignOutState,
    () => Promise<Pick<UseSignOutState, 'error'>>,
]

const initialStateSignOut = {
    error: undefined,
    fetching: false,
}

export function useSignOut(): UseSignOutResponse {


    const client = useSupabaseClient()
    const [state, setState] = useState<UseSignOutState>(initialStateSignOut)

    const execute = useCallback(async () => {
        setState({ ...initialStateSignOut, fetching: true })
        const { error } = await client.auth.signOut()
        const res = { error }
        setState({ ...res, fetching: false })
        return res
    }, [client])

    return [state, execute]
}


type WithChildren<T = {}> =
    T & { children?: React.ReactNode };



export function useAuthStateChange(
    callback: (event: AuthChangeEvent, session: Session | null) => void,
) {
    const client = useSupabaseClient()

    useEffect(() => {
        const { data: authListener } = client.auth.onAuthStateChange(callback)
        return () => {
            authListener?.unsubscribe()
        }
    }, [])
}


const authInitialState = { session: null, user: null }
export const AuthContext = createContext<{ session: Session | null, user: Session["user"] | null } | undefined>(undefined)

export function AuthProvider({ children }: WithChildren) {
    const client = useSupabaseClient()
    const [state, setState] = useState<{ session: Session | null, user: Session["user"] | null }>(authInitialState)
    console.log('state: ', state);

    useEffect(() => {
        const session = client.auth.session()
        setState({ session, user: session?.user ?? null })
    }, [])

    useAuthStateChange((event, session) => {
        console.log(`Supbase auth event: ${event}`, session)
        setState({ session, user: session?.user ?? null })
    })

    return <AuthContext.Provider value={state}>{children}</AuthContext.Provider>
}

export function useAuth() {
    const context = useContext(AuthContext)
    if (context === undefined)
        throw Error('useAuth must be used within AuthProvider')
    return context
}