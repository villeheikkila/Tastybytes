import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { unstable_parseMultipartFormData } from "@remix-run/node";
import { Form, useLoaderData } from "@remix-run/react";
import { authenticator } from "~/auth.server";
import { Avatar } from "~/components/avatar";
import { supabaseClient } from "~/supabase";
import { paths } from "~/utils";
import { Configs } from "~/utils/configs";

export const action: ActionFunction = async ({ request }) => {
  const session = await authenticator.isAuthenticated(request);
  if (!session) throw Error("User is not logged in!");
  supabaseClient.auth.setAuth(session.access_token);

  const uploadHandler = async ({
    name,
    stream,
    filename,
  }: {
    name: string;
    filename: string;
    stream: any;
  }) => {
    if (name !== "avatar") {
      stream.resume();
      return;
    } else {
      console.log(name, filename);
    }

    const chunks = [];
    for await (const chunk of stream) chunks.push(chunk);
    const buffer = Buffer.concat(chunks);

    const { data, error: uploadError } = await supabaseClient.storage
      .from("avatars")
      .upload(session?.user?.id + "/" + filename, buffer);

    if (uploadError) {
      throw uploadError;
    }

    if (data?.Key) {
      let { error } = await supabaseClient.from("profiles").upsert({
        id: session?.user?.id,
        avatar_url: data.Key,
      });

      console.log("error: ", error);
    }

    return JSON.stringify({ data });
  };

  await unstable_parseMultipartFormData(request, uploadHandler);

  return null;
};

export const loader: LoaderFunction = async ({ request }) => {
  const session = await authenticator.isAuthenticated(request);
  const { data: user } = await supabaseClient
    .from("profiles")
    .select("*")
    .eq("id", session?.user?.id)
    .single();

  return { user, supabaseUrl: Configs.supabaseUrl };
};
export default function Index() {
  const { user, supabaseUrl } = useLoaderData();

  return (
    <>
      <h1>Settings</h1>

      <Form method="post" encType="multipart/form-data">
        <label htmlFor="avatar-input">Avatar</label>
        <input id="avatar" type="file" name="avatar" accept="image/*" />
        <button>Upload</button>
        {user && (
          <Avatar
            imageUrl={paths.avatarUrl({
              profilePic: user.avatar_url,
              supabaseUrl,
            })}
            name={user.username}
          />
        )}
      </Form>
    </>
  );
}
