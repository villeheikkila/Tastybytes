import { NextApiRequest, NextApiResponse } from 'next'
import { supabase } from '../../utils/initSupabase'

export default async (req: NextApiRequest, res: NextApiResponse) => {
  const token = req.headers.token
  const { data: user, error } = await supabase.auth.api.getUser(String(token))
  if (error) return res.status(401).json({ error: error.message })
  return res.status(200).json(user)
}

