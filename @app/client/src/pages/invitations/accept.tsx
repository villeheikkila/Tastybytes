import { QueryResult } from "@apollo/client";
import {
  AuthRestrict,
  ButtonLink,
  ErrorAlert,
  Redirect,
  SharedLayout,
  SpinPadded,
} from "@app/components";
import {
  InvitationDetailQuery,
  InvitationDetailQueryVariables,
  SharedLayout_UserFragment,
  useAcceptOrganizationInviteMutation,
  useInvitationDetailQuery,
} from "@app/graphql";
import { getCodeFromError } from "@app/lib";
import { NextPage } from "next";
import Router, { NextRouter, useRouter } from "next/router";
import * as qs from "querystring";
import React, { FC } from "react";

interface IProps {
  id: string | null;
  code: string | null;
}

enum Status {
  PENDING = "PENDING",
  ACCEPTING = "ACCEPTING",
}

const InvitationAccept: NextPage<IProps> = (props) => {
  const router: NextRouter | null = useRouter();
  const fullHref =
    router.pathname +
    (router && router.query ? `?${qs.stringify(router.query)}` : "");
  const { id: rawId, code } = props;
  const id = rawId || "";
  const query = useInvitationDetailQuery({
    variables: {
      id,
      code,
    },
    skip: !id,
    fetchPolicy: "network-only",
  });
  return (
    <SharedLayout
      title="Accept Invitation"
      query={query}
      noHandleErrors
      forbidWhen={AuthRestrict.LOGGED_OUT}
    >
      {({ currentUser, error, loading }) =>
        !currentUser && !error && !loading ? (
          <Redirect href={`/login?next=${encodeURIComponent(fullHref)}`} />
        ) : (
          <div>
            <div>
              <InvitationAcceptInner
                currentUser={currentUser}
                id={id}
                code={code}
                query={query}
              />
            </div>
          </div>
        )
      }
    </SharedLayout>
  );
};

interface InvitationAcceptInnerProps extends IProps {
  currentUser?: SharedLayout_UserFragment | null;
  query: QueryResult<InvitationDetailQuery, InvitationDetailQueryVariables>;
}

const InvitationAcceptInner: FC<InvitationAcceptInnerProps> = (props) => {
  const { id, code, query } = props;
  const router = useRouter();

  const { data, loading, error } = query;
  const [acceptInvite] = useAcceptOrganizationInviteMutation();

  const [status, setStatus] = React.useState(Status.PENDING);
  const [acceptError, setAcceptError] = React.useState<Error | null>(null);

  const organization = data?.organizationForInvitation;
  const handleAccept = React.useCallback(() => {
    if (!organization) {
      return;
    }
    setStatus(Status.ACCEPTING);
    // Call mutation
    acceptInvite({
      variables: {
        id,
        code,
      },
    }).then(
      () => {
        // Redirect
        Router.push(`/o/[slug]`, `/o/${organization.slug}`);
      },
      (e) => {
        setStatus(Status.PENDING);
        setAcceptError(e);
      }
    );
  }, [acceptInvite, code, id, organization]);

  let child: JSX.Element | null = null;
  if (status === Status.ACCEPTING) {
    child = <SpinPadded />;
  } else if (error || acceptError) {
    const code = getCodeFromError(error || acceptError);
    if (code === "NTFND") {
      child = (
        <div>
          status="404" title="That invitation could not be found"
          subTitle="Perhaps you have already accepted it?"
        </div>
      );
    } else if (code === "DNIED") {
      child = (
        <div>
          status="403" title="That invitation is not for you" subTitle="Perhaps
          you should log out and log in with a different account?"
        </div>
      );
    } else if (code === "LOGIN") {
      child = (
        <div>
          status="403" title="Log in to accept invitation"
          <ButtonLink href={`/login?next=${encodeURIComponent(router.asPath)}`}>
            Log in
          </ButtonLink>
        </div>
      );
    } else {
      child = <ErrorAlert error={error || acceptError!} />;
    }
  } else if (organization) {
    child = (
      <div>
        status="success" title={`You were invited to ${organization.name}`}
        extra={<button onClick={handleAccept}>Accept invitation</button>}
      </div>
    );
  } else if (loading) {
    child = <div />;
  } else {
    child = (
      <div>
        status="error" title="Something went wrong" subTitle="We couldn't find
        details about this invite, please try again later"
      </div>
    );
  }
  return child;
};

InvitationAccept.getInitialProps = async ({ query: { id, code } }) => ({
  id: typeof id === "string" ? id : null,
  code: typeof code === "string" ? code : null,
});

export default InvitationAccept;
