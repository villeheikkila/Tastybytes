import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import {
  unstable_createFileUploadHandler,
  unstable_parseMultipartFormData,
} from "@remix-run/node";
import { Form, useLoaderData } from "@remix-run/react";
import { authenticator } from "~/auth.server";
import { supabaseClient } from "~/supabase";

export const action: ActionFunction = async ({ request }) => {
  const session = await authenticator.isAuthenticated(request);
  if (!session) throw Error("User is not logged in!");
  supabaseClient.auth.setAuth(session.access_token);

  const uploadHandler = unstable_createFileUploadHandler({
    maxFileSize: 5_000_000,
    file: ({ filename }) => filename,
  });
  const formData = await unstable_parseMultipartFormData(
    request,
    uploadHandler
  );

  const file = formData.get("avatar");
  console.log("file: ", file);

  if (file && session?.user?.id) {
    const { data, error } = await supabaseClient.storage
      .from("avatars")
      .upload(`${session?.user?.id}/${(file as unknown as any).name}`, file, {
        contentType: (file as unknown as any).type,
        cacheControl: "3600",
        upsert: true,
      });

    if (data?.Key) {
      let { error } = await supabaseClient.from("profiles").upsert({
        id: session?.user?.id,
        avatar_url: data.Key,
      });

      console.log("error: ", error);
    }
  }

  return null;
};

export const loader: LoaderFunction = async ({ request }) => {
  const session = await authenticator.isAuthenticated(request);
  const { data: user } = await supabaseClient
    .from("profiles")
    .select("*")
    .eq("id", session?.user?.id)
    .single();

  return { user };
};
export default function Index() {
  const { user } = useLoaderData();

  return (
    <>
      <h1>Settings</h1>

      <Form method="post" encType="multipart/form-data">
        <label htmlFor="avatar-input">Avatar</label>
        <input id="avatar-input" type="file" name="avatar" />
        <button>Upload</button>
        {user && (
          <img
            src={
              "https://iykihowuxxkqxobggkuk.supabase.co/storage/v1/object/public/" +
              user.avatar_url
            }
            alt="avatar"
          />
        )}
      </Form>
    </>
  );
}
