import { QueryResult } from "@apollo/client";
import { OrganizationPage_QueryFragment } from "@app/graphql";
import { useRouter } from "next/router";
import React from "react";

import { ErrorAlert, FourOhFour } from "./";
import { SpinPadded } from "./SpinPadded";

export function useOrganizationSlug() {
  const router = useRouter();
  const { slug: rawSlug } = router.query;
  return String(rawSlug);
}

export function useOrganizationLoading(
  query: Pick<
    QueryResult<OrganizationPage_QueryFragment>,
    "data" | "loading" | "error" | "networkStatus" | "client" | "refetch"
  >
) {
  const { data, loading, error } = query;
  console.log("data: ", data);

  let child: JSX.Element | null = null;
  const organization = data?.organizationBySlug;
  if (organization) {
    //child = <OrganizationPageInner organization={organization} />;
  } else if (loading) {
    child = <SpinPadded />;
  } else if (error) {
    child = <ErrorAlert error={error} />;
  } else {
    // TODO: 404
    child = <FourOhFour currentUser={data?.currentUser} />;
  }

  return child ? (
    <div>
      <div>{child}</div>
    </div>
  ) : null;
}
