import {
  AuthRestrict,
  OrganizationSettingsLayout,
  Redirect,
  SharedLayout,
  useOrganizationLoading,
  useOrganizationSlug,
} from "@app/components";
import {
  OrganizationMembers_MembershipFragment,
  OrganizationMembers_OrganizationFragment,
  SharedLayout_UserFragment,
  useInviteToOrganizationMutation,
  useOrganizationMembersQuery,
  useRemoveFromOrganizationMutation,
  useTransferOrganizationBillingContactMutation,
  useTransferOrganizationOwnershipMutation,
} from "@app/graphql";
import { NextPage } from "next";
import { useRouter } from "next/router";
import React, { FC, useCallback, useState } from "react";
import { useForm } from "react-hook-form";

const OrganizationSettingsPage: NextPage = () => {
  const slug = useOrganizationSlug();
  const [page, setPage] = useState(1);
  const query = useOrganizationMembersQuery({
    variables: {
      slug,
      offset: (page - 1) * RESULTS_PER_PAGE,
    },
  });
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
      {({ currentUser }) =>
        organizationLoadingElement || (
          <OrganizationSettingsPageInner
            organization={organization!}
            currentUser={currentUser}
            page={page}
            setPage={setPage}
          />
        )
      }
    </SharedLayout>
  );
};

interface OrganizationSettingsPageInnerProps {
  currentUser?: SharedLayout_UserFragment | null;
  organization: OrganizationMembers_OrganizationFragment;
  page: number;
  setPage: (newPage: number) => void;
}

// This needs to match the `first:` used in OrganizationMembers.graphql
const RESULTS_PER_PAGE = 10;

interface InvitationFormValues {
  inviteText: string;
}

const OrganizationSettingsPageInner: FC<OrganizationSettingsPageInnerProps> = (
  props
) => {
  const { organization, currentUser, page, setPage } = props;
  const router = useRouter();
  const [status, setStatus] = useState("");

  const renderItem = useCallback(
    (node: OrganizationMembers_MembershipFragment) => (
      <OrganizationMemberListItem
        node={node}
        organization={organization}
        currentUser={currentUser}
      />
    ),
    [currentUser, organization]
  );

  const [inviteToOrganization] = useInviteToOrganizationMutation();
  const [inviteInProgress, setInviteInProgress] = useState(false);
  const { register, handleSubmit, reset } = useForm<InvitationFormValues>();
  const onSubmit = useCallback(
    async (values: InvitationFormValues) => {
      if (inviteInProgress) {
        return;
      }
      const { inviteText } = values;
      setInviteInProgress(true);
      const isEmail = inviteText.includes("@");
      try {
        await inviteToOrganization({
          variables: {
            organizationId: organization.id,
            email: isEmail ? inviteText : null,
            username: isEmail ? null : inviteText,
          },
        });
        setStatus(`'${inviteText}' invited.`);
        reset({ inviteText: "" });
      } catch (e) {
        // TODO: handle this through the interface
        setStatus(
          "Could not invite to organization: " +
            e.message.replace(/^GraphQL Error:/i, "")
        );
      } finally {
        setInviteInProgress(false);
      }
    },
    [reset, inviteInProgress, inviteToOrganization, organization.id]
  );

  if (
    !organization.currentUserIsBillingContact &&
    !organization.currentUserIsOwner
  ) {
    return <Redirect as={`/o/${organization.slug}`} href="/o/[slug]" />;
  }

  const handlePaginationChange = (
    page: number
    //pageSize?: number | undefined
  ) => {
    setPage(page);
  };

  return (
    <OrganizationSettingsLayout organization={organization} href={router.route}>
      <div>
        <h1>Members</h1>
        <div>Invite new member</div>
        <form onSubmit={handleSubmit(onSubmit)}>
          <input
            placeholder="Username or email"
            id="inviteText"
            disabled={inviteInProgress}
            {...register("inviteText", { required: true })}
          />
          <input type="submit">Invite</input>
        </form>
        {status}
      </div>
      current page: {page}
      pageSize: {RESULTS_PER_PAGE}
      total={organization.organizationMemberships?.totalCount},
      <button onClick={() => handlePaginationChange(page + 1)}>
        change page
      </button>
      <div>
        {organization.organizationMemberships?.nodes?.map((member) =>
          renderItem(member)
        )}
      </div>
    </OrganizationSettingsLayout>
  );
};

interface OrganizationMemberListItemProps {
  node: OrganizationMembers_MembershipFragment;
  organization: OrganizationMembers_OrganizationFragment;
  currentUser?: SharedLayout_UserFragment | null;
}

const OrganizationMemberListItem: FC<OrganizationMemberListItemProps> = (
  props
) => {
  const { node, organization, currentUser } = props;
  const [status, setStatus] = useState("");

  const [removeMember] = useRemoveFromOrganizationMutation();
  const handleRemove = useCallback(async () => {
    try {
      await removeMember({
        variables: {
          organizationId: organization.id,
          userId: node.user?.id ?? 0,
        },
        refetchQueries: ["OrganizationMembers"],
      });
    } catch (e) {
      setStatus("Error occurred when removing member: " + e.message);
    }
  }, [node.user, organization.id, removeMember]);

  const [transferOwnership] = useTransferOrganizationOwnershipMutation();
  const handleTransfer = useCallback(async () => {
    try {
      await transferOwnership({
        variables: {
          organizationId: organization.id,
          userId: node.user?.id ?? 0,
        },
        refetchQueries: ["OrganizationMembers"],
      });
    } catch (e) {
      setStatus("Error occurred when transferring ownership: " + e.message);
    }
  }, [node.user, organization.id, transferOwnership]);

  const [transferBilling] = useTransferOrganizationBillingContactMutation();
  const handleBillingTransfer = useCallback(async () => {
    try {
      await transferBilling({
        variables: {
          organizationId: organization.id,
          userId: node.user?.id ?? 0,
        },
        refetchQueries: ["OrganizationMembers"],
      });
    } catch (e) {
      setStatus(
        "Error occurred when transferring billing contact: " + e.message
      );
    }
  }, [node.user, organization.id, transferBilling]);

  const roles = [
    node.isOwner ? "owner" : null,
    node.isBillingContact ? "billing contact" : null,
  ]
    .filter(Boolean)
    .join(" and ");
  return (
    <div>
      {[
        organization.currentUserIsOwner && node.user?.id !== currentUser?.id ? (
          <button onClick={handleRemove}>
            {`Are you sure you want to remove ${node.user?.name} from ${organization.name}?`}
            okText="Yes" cancelText="No" key="remove"
            <a>Remove</a>
          </button>
        ) : null,
        organization.currentUserIsOwner && node.user?.id !== currentUser?.id ? (
          <button onClick={handleTransfer}>
            {`Are you sure you want to transfer ownership of ${organization.name} to ${node.user?.name}?`}
            okText="Yes" cancelText="No" key="transfer"
            <a>Make owner</a>
          </button>
        ) : null,
        organization.currentUserIsOwner && !node.isBillingContact ? (
          <button onClick={handleBillingTransfer}>
            {`Are you sure you want to make ${node.user?.name} the billing contact for ${organization.name}?`}
            okText="Yes" cancelText="No" key="billingTransfer"
            <a>Make billing contact</a>
          </button>
        ) : null,
      ].filter(Boolean)}
      {status}
      <div>
        {node.user?.name}
        <div>
          <p>{node.user?.username}</p>
          {roles ? (
            <div>
              <p>({roles})</p>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
};

export default OrganizationSettingsPage;
