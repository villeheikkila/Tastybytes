import {
  ButtonLink,
  SharedLayout,
  useOrganizationLoading,
  useOrganizationSlug,
} from "@app/components";
import {
  OrganizationPage_OrganizationFragment,
  useOrganizationPageQuery,
} from "@app/graphql";
import { NextPage } from "next";
import React, { FC } from "react";

const OrganizationPage: NextPage = () => {
  const slug = useOrganizationSlug();
  const query = useOrganizationPageQuery({ variables: { slug } });
  const organizationLoadingElement = useOrganizationLoading(query);
  const organization = query?.data?.organizationBySlug;

  return (
    <SharedLayout
      title={`${organization?.name ?? slug}`}
      titleHref={`/o/[slug]`}
      titleHrefAs={`/o/${slug}`}
      query={query}
    >
      {organizationLoadingElement || (
        <OrganizationPageInner organization={organization!} />
      )}
    </SharedLayout>
  );
};

interface OrganizationPageInnerProps {
  organization: OrganizationPage_OrganizationFragment;
}

const OrganizationPageInner: FC<OrganizationPageInnerProps> = (props) => {
  const { organization } = props;

  return (
    <div>
      <div>
        <header>
          Dashboard
          {organization.currentUserIsBillingContact ||
          organization.currentUserIsOwner
            ? [
                <ButtonLink
                  key="settings"
                  href={`/o/[slug]/settings`}
                  // as={`/o/${organization.slug}/settings`}
                >
                  Settings
                </ButtonLink>,
              ]
            : null}
        </header>

        <span>
          Customize this page in
          <br />
          <code>@app/client/src/pages/o/[slug]/index.tsx</code>
        </span>
      </div>
    </div>
  );
};

export default OrganizationPage;
