/**
 * NOTE: this file is only needed if you're doing SSR (getServerSideProps)!
 */
import { NextApiRequest, NextApiResponse } from 'next'
import { supabase } from '../../utils/initSupabase'

export default (req: NextApiRequest, res: NextApiResponse) => {
  supabase.auth.api.setAuthCookie(req, res)
}
