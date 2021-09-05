import { ApolloError } from "@apollo/client";
import { AuthRestrict, Redirect, SharedLayout } from "@app/components";
import {
  CreatedOrganizationFragment,
  useCreateOrganizationMutation,
  useOrganizationBySlugLazyQuery,
  useSharedQuery,
} from "@app/graphql";
import { extractError, getCodeFromError } from "@app/lib";
import { debounce } from "lodash";
import { NextPage } from "next";
import React, { useCallback, useEffect, useMemo, useState } from "react";
import { useForm } from "react-hook-form";
import slugify from "slugify";

interface CreateOrganizationForm {
  name: string;
}

const CreateOrganizationPage: NextPage = () => {
  const [formError, setFormError] = useState<Error | ApolloError | null>(null);
  const query = useSharedQuery();
  const { register, handleSubmit, watch } = useForm();
  const [slug, setSlug] = useState("");
  const [
    lookupOrganizationBySlug,
    { data: existingOrganizationData, loading: slugLoading, error: slugError },
  ] = useOrganizationBySlugLazyQuery();

  const [slugCheckIsValid, setSlugCheckIsValid] = useState(false);
  const checkSlug = useMemo(
    () =>
      debounce(async (slug: string) => {
        try {
          if (slug) {
            await lookupOrganizationBySlug({
              variables: {
                slug,
              },
            });
          }
        } catch (e) {
          /* NOOP */
        } finally {
          setSlugCheckIsValid(true);
        }
      }, 500),
    [lookupOrganizationBySlug]
  );

  useEffect(() => {
    const name = watch("name");
    setSlug(
      slugify(name, {
        lower: true,
      })
    );
    checkSlug(name);
  }, [checkSlug, slug, watch, setSlug]);

  const code = getCodeFromError(formError);
  const [organization, setOrganization] =
    useState<null | CreatedOrganizationFragment>(null);
  const [createOrganization] = useCreateOrganizationMutation();

  const onSubmit = useCallback(
    async (values: CreateOrganizationForm) => {
      setFormError(null);
      try {
        const { name } = values;
        const slug = slugify(name || "", {
          lower: true,
        });
        const { data } = await createOrganization({
          variables: {
            name,
            slug,
          },
        });
        setFormError(null);
        setOrganization(data?.createOrganization?.organization || null);
      } catch (e) {
        setFormError(e);
      }
    },
    [createOrganization]
  );

  if (organization) {
    return (
      <Redirect layout href={`/o/[slug]`} as={`/o/${organization.slug}`} />
    );
  }

  return (
    <SharedLayout title="" query={query} forbidWhen={AuthRestrict.LOGGED_OUT}>
      <div>
        <div>
          <h1>Create Organization" </h1>
          <div>
            <form onSubmit={handleSubmit(onSubmit)}>
              <input
                placeholder="Name"
                {...register("name", { required: true })}
              />
              <div>
                <input />
                <p>
                  Your organization URL will be{" "}
                  <span>{`${process.env.ROOT_URL}/o/${slug}`}</span>
                </p>
                {!slug ? null : !slugCheckIsValid || slugLoading ? (
                  <div>Checking organization name</div>
                ) : existingOrganizationData?.organizationBySlug ? (
                  <p>Organization name is already in use</p>
                ) : slugError ? (
                  <p>
                    Error occurred checking for existing organization with this
                    name (error code: ERR_{getCodeFromError(slugError)})
                  </p>
                ) : null}
              </div>
              {formError ? (
                <div>
                  Creating organization failed
                  <span>
                    {code === "NUNIQ" ? (
                      <span>
                        That organization name is already in use, please choose
                        a different organization name.
                      </span>
                    ) : (
                      extractError(formError).message
                    )}
                    {code ? (
                      <span>
                        {" "}
                        (Error code: <code>ERR_{code}</code>)
                      </span>
                    ) : null}
                  </span>
                </div>
              ) : null}
              <button type="submit">Create</button>
            </form>
          </div>
        </div>
      </div>
    </SharedLayout>
  );
};

export default CreateOrganizationPage;
