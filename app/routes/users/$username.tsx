import { useEffect } from "react";
import { useInView } from "react-intersection-observer";
import { Link, LoaderFunction, useLoaderData, useSearchParams } from "remix";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { getDisplayName } from "~/utils";
import { paths } from "~/utils/paths";

interface UserPageLoader {
  profileData: SDK.GetProfilePageByUsernameQuery["userByUsername"];
}
export const loader: LoaderFunction = async ({
  request,
  params,
}): Promise<UserPageLoader> => {
  if (!params.username) {
    throw new Response("Not found.", { status: 404 });
  }

  const url = new URL(request.url);
  const cursor = url.searchParams.get("cursor");

  const profilePageData = await sdk().getProfilePageByUsername({
    username: params.username,
    cursor: cursor,
    includeBefore: !!cursor,
  });

  return {
    profileData: profilePageData.userByUsername,
  };
};

export default function Index() {
  const [searchParams, setSearchParams] = useSearchParams();
  const { profileData } = useLoaderData<UserPageLoader>();
  const { ref, inView } = useInView();

  useEffect(() => {
    const cursor = profileData?.authoredCheckIns.edges.at(-1)?.cursor;
    if (!!cursor && searchParams.get("cursor") !== cursor) {
      setSearchParams({ cursor });
    }
  }, [inView]);

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>
          {profileData && getDisplayName(profileData)}
        </Typography.H1>
      </Layout.Header>
      <Card.Container>
        {(profileData?.before?.edges ?? [])
          .concat(profileData?.authoredCheckIns?.edges ?? [])
          .map(({ node }) => (
            <Card.Wrapper key={node?.id}>
              <p>
                <b>{getDisplayName(profileData)}</b> has tasted{" "}
                <Link
                  to={paths.products(node?.product?.id ?? 0)}
                >{`${node?.product?.brand?.name} - ${node?.product?.name}`}</Link>{" "}
                by{" "}
                <Link to={paths.company(node?.product.brand.company.id)}>
                  {node?.product?.brand?.company?.name}
                </Link>
              </p>
              {node?.rating && <Stars rating={node?.rating} />}
            </Card.Wrapper>
          ))}
        <div ref={ref} />
      </Card.Container>
    </Layout.Root>
  );
}
