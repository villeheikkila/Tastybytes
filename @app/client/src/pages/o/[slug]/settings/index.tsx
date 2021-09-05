import {
  AuthRestrict,
  OrganizationSettingsLayout,
  Redirect,
  SharedLayout,
  useOrganizationLoading,
  useOrganizationSlug,
} from "@app/components";
import {
  OrganizationPage_OrganizationFragment,
  useOrganizationPageQuery,
  useUpdateOrganizationMutation,
} from "@app/graphql";
import { extractError } from "@app/lib";
import { NextPage } from "next";
import Router, { useRouter } from "next/router";
import React, { FC, useCallback, useState } from "react";
import { useForm } from "react-hook-form";

const OrganizationSettingsPage: NextPage = () => {
  const slug = useOrganizationSlug();
  const query = useOrganizationPageQuery({ variables: { slug } });
  const organizationLoadingElement = useOrganizationLoading(query);
  const organization = query?.data?.organizationBySlug;

  return (
    <SharedLayout
      title={organization?.name ?? slug}
      titleHref={`/o/[slug]`}
      titleHrefAs={`/o/${slug}`}
      noPad
      query={query}
      forbidWhen={AuthRestrict.LOGGED_OUT}
    >
      {organizationLoadingElement || (
        <OrganizationSettingsPageInner organization={organization!} />
      )}
    </SharedLayout>
  );
};

interface OrganizationSettingsPageInnerProps {
  organization: OrganizationPage_OrganizationFragment;
}

interface OrganizationSettingsForm {
  slug: string;
  name: string;
}

const OrganizationSettingsPageInner: FC<OrganizationSettingsPageInnerProps> = (
  props
) => {
  const { organization } = props;
  const { name, slug } = organization;
  const router = useRouter();

  const { register, handleSubmit } = useForm<OrganizationSettingsForm>({
    defaultValues: { slug, name },
  });

  const [status, setStatus] = useState("");
  const [updateOrganization] = useUpdateOrganizationMutation();
  const [error, setError] = useState<Error | null>(null);

  const onSubmit = useCallback(
    async (values: OrganizationSettingsForm) => {
      try {
        setError(null);
        const { data } = await updateOrganization({
          variables: {
            input: {
              id: organization.id,
              patch: { slug: values.slug, name: values.name },
            },
          },
        });
        setStatus("Organization updated");
        const newSlug = data?.updateOrganization?.organization?.slug;
        if (newSlug && newSlug !== organization.slug) {
          Router.push(`/o/[slug]/settings`, `/o/${newSlug}/settings`);
        }
      } catch (e) {
        setError(e);
      }
    },
    [organization.id, organization.slug, updateOrganization]
  );

  if (
    !organization.currentUserIsBillingContact &&
    !organization.currentUserIsOwner
  ) {
    return <Redirect as={`/o/${organization.slug}`} href="/o/[slug]" />;
  }

  return (
    <OrganizationSettingsLayout organization={organization} href={router.route}>
      <div>
        <h1>Profile</h1>
        <form onSubmit={handleSubmit(onSubmit)}>
          <input
            placeholder="Organization name"
            {...register("name", { required: true, min: 1 })}
          />
          <input
            placeholder="Slug"
            {...register("slug", { required: true, min: 2 })}
          />
          {error ? (
            <div>
              type="error" message={`Updating organization`}
              description: {<span>{extractError(error).message}</span>}
            </div>
          ) : null}
          <button type="submit">Update organization</button>
          {status}
        </form>
      </div>
    </OrganizationSettingsLayout>
  );
};

export default OrganizationSettingsPage;
