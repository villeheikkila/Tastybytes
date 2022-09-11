import { Auth } from '@supabase/ui';
import { useUser } from '@supabase/auth-helpers-react';
import { supabaseClient } from '@supabase/auth-helpers-nextjs';
import { useEffect, useState } from 'react';

const LoginPage = () => {
  const { user, error } = useUser();
  console.log('error: ', error);
  console.log('user: ', user);
  const [data, setData] = useState<any>();
  console.log('data: ', data);

  useEffect(() => {
    async function loadData() {
      const { data, error } = await supabaseClient.from('companies').select('*');
      console.log('error: ', error);
      setData(data);
    }
    if (user) loadData();
  }, [user]);

  if (!user)
    return (
      <>
        {error && <p>{error.message}</p>}
        <Auth
          supabaseClient={supabaseClient}
          providers={[]}
          socialLayout="horizontal"
          socialButtonSize="xlarge"
        />
      </>
    );

  return (
    <div>
      <button onClick={() => supabaseClient.auth.signOut()}>Sign out</button>
      <p>user:</p>
      <pre>{JSON.stringify(user, null, 2)}</pre>
      <p>client-side data fetching with RLS</p>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};

export default LoginPage;