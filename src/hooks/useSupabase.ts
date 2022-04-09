import { SupabaseClient } from '@supabase/supabase-js'
import { createContext, useContext } from 'react'

export const SupabaseContext = createContext<SupabaseClient | undefined>(undefined)

export const SupabaseProvider = SupabaseContext.Provider

export const Consumer = SupabaseContext.Consumer

SupabaseContext.displayName = 'SupabaseContext'

export function useSupabaseClient(): SupabaseClient {
    const client = useContext(SupabaseContext)
    if (client === undefined)
        throw Error('No client has been specified using Provider.')
    return client
}