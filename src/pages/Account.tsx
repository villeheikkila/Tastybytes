import { useEffect, useState } from "react";
import { useGetCheckInsQuery } from "../generated/graphql";
import { useAuth } from "../hooks/useAuth";
import { useSupabaseClient } from "../hooks/useSupabase";

const Account = () => {
  const { session } = useAuth();
  const [loading, setLoading] = useState(true);
  const [username, setUsername] = useState<string | null>(null);
  const [website, setWebsite] = useState<string | null>(null);
  const [avatar_url, setAvatarUrl] = useState<string | null>(null);

  const client = useSupabaseClient();

  useEffect(() => {
    getProfile();
    getCompanies();
  }, [session]);

  const getProfile = async () => {
    try {
      setLoading(true);
      const user = client.auth.user();

      let { data, error, status } = await client
        .from("profiles")
        .select(`username, website, avatar_url`)
        .eq("id", user?.id)
        .single();

      if (error && status !== 406) {
        throw error;
      }

      if (data) {
        setUsername(data.username);
        setWebsite(data.website);
        setAvatarUrl(data.avatar_url);
      }
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const getCompanies = async () => {
    try {
      let { data: companies, error } = await client
        .from("companies")
        .select("*");

      console.log("companies: ", companies);
    } catch (e) {
      console.error(e);
    }
  };

  const updateProfile = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    try {
      setLoading(true);
      const user = client.auth.user();

      const updates = {
        id: user?.id,
        username,
        website,
        avatar_url,
        updated_at: new Date(),
      };

      let { error } = await client.from("profiles").upsert(updates, {
        returning: "minimal", // Don't return the value after inserting
      });

      if (error) {
        throw error;
      }
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div aria-live="polite">
      {loading ? (
        "Saving ..."
      ) : (
        <form onSubmit={updateProfile} className="form-widget">
          <div>Email: {sessio?.user?.email}</div>
          <div>
            <label htmlFor="username">Name</label>
            <input
              id="username"
              type="text"
              value={username || ""}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>
          <div>
            <label htmlFor="website">Website</label>
            <input
              id="website"
              type="url"
              value={website || ""}
              onChange={(e) => setWebsite(e.target.value)}
            />
          </div>
          <div>
            <button className="button block primary" disabled={loading}>
              Update profile
            </button>
          </div>
        </form>
      )}
      <button
        type="button"
        className="button block"
        onClick={() => client.auth.signOut()}
      >
        Sign Out
      </button>
    </div>
  );
};

export default Account;
