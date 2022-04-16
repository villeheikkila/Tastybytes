import { Card, Grid, Row, Text } from "@nextui-org/react";
import { GetServerSideProps } from "next";
import { Stars } from "../../../components/Stars";
import { supabase } from "../../../utils/initSupabase";

interface UserPageProps {
  checkIns: any[];
}

export default function UserPage({ checkIns }: UserPageProps) {
  console.log("checkIns: ", checkIns);
  return (
    <Grid.Container gap={2}>
      <Grid sm={12} md={5} direction="column" css={{ gap: "1rem" }}>
        {checkIns.map((checkIn) => (
          <Card key={checkIn.id} css={{ mw: "30rem" }}>
            <Row css={{ gap: "6px" }}>
              <Text h4>
                {checkIn.profiles.username} is tasting{" "}
                {checkIn.products.sub_brands.brands.name}{" "}
                {checkIn.products.sub_brands.name} {checkIn.products.name} by{" "}
                {checkIn.products.sub_brands.brands.companies.name}
              </Text>
            </Row>
            <Card.Footer>
              <Stars rating={checkIn.rating / 2} />
            </Card.Footer>
          </Card>
        ))}
      </Grid>
    </Grid.Container>
  );
}

export const getServerSideProps: GetServerSideProps = async ({
  req,
  params,
}) => {
  const { user } = await supabase.auth.api.getUserByCookie(req);

  if (!user || !params?.slug) {
    return { props: {}, redirect: { destination: "/", permanent: false } };
  } else {
    const { data: checkIns, error } = await supabase
      .from("check_ins")
      .select(
        `id, rating, review, products (id, name, description, companies (id, name), sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), profiles!inner(username)`
      )
      .eq("profiles.username", String(params.slug))
      .limit(10);

    if (error) {
      console.log("error: ", error);
    }

    return { props: { checkIns } };
  }
};
