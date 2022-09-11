import {
    User,
    withPageAuth,
    supabaseServerClient
  } from '@supabase/auth-helpers-nextjs';
  
  export default function ProfilePage({
    user,
    data
  }: {
    user: User,
    data: any
  }) {
    return (
      <>
        <div>Protected content for {user.email}</div>
        <pre>{JSON.stringify(data, null, 2)}</pre>
        <pre>{JSON.stringify(user, null, 2)}</pre>
      </>
    );
  }
  
  export const getServerSideProps = withPageAuth({
    redirectTo: '/',
    async getServerSideProps(ctx) {
      // Run queries with RLS on the server
      const { data } = await supabaseServerClient(ctx).from('profiles').select('*');
      return { props: { data } };
    }
  });