import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
console.log('supabaseUrl: ', supabaseUrl);
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY
console.log('supabaseAnonKey: ', supabaseAnonKey);

export const supabase = createClient(supabaseUrl, supabaseAnonKey)