import { serve } from "https://deno.land/std@0.131.0/http/server.ts";
import { createOAuth2Token } from "https://deno.land/x/deno_gcp_admin/auth.ts";
import { decode as base64Decode } from "https://deno.land/std/encoding/base64.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0";

serve(async () => {
  // Base64 encoded contents of Google Service Account credentials
  const serviceAccount = Deno.env.get("GOOGLE_SERVICE_ACCOUNT") ?? "";
  const textDecoder = new TextDecoder("utf-8");
  const serviceAccountCredentials = JSON.parse(
    textDecoder.decode(base64Decode(serviceAccount)),
  );

  const adminSupabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  if (serviceAccountCredentials) {
    const tokens = await createOAuth2Token(
      {
        client_email: serviceAccountCredentials?.client_email,
        private_key: serviceAccountCredentials?.private_key,
        private_key_id: serviceAccountCredentials?.private_key_id,
      },
      "https://www.googleapis.com/auth/firebase.messaging",
    );
    const accessToken = tokens?.accessToken.slice(0, 232);

    await adminSupabaseClient.from("secrets").upsert({
      "supabase_anon_key": Deno.env.get("SUPABASE_ANON_KEY"),
      "firebase_access_token": accessToken,
      "supabase_url": Deno.env.get("SUPABASE_URL"),
      "firebase_project_id": serviceAccountCredentials?.project_id,
    });

    return new Response(null, { status: 200 });
  }

  return new Response(null, { status: 500 });
});
