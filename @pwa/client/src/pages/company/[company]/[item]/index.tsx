import {
  Button,
  Card,
  Input,
  Layout,
  SharedLayout,
  Stars,
  StarSelector,
  styled,
} from "@pwa/components";
import { ProductByIdQuery, useProductByIdQuery } from "@pwa/graphql";
import { getDisplayName } from "@pwa/common";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";
import { useForm } from "react-hook-form";

const ProductPage = () => {
  const router = useRouter();
  const item = router.query.item;
  const itemId = parseInt(String(item), 10);
  const productById = useProductByIdQuery({
    variables: {
      itemId: itemId ?? -1,
    },
  });

  const data = productById?.data?.item;

  return (
    <SharedLayout title={`${item}`} query={productById}>
      {data && <ProductPageInner data={data} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: NonNullable<ProductByIdQuery["item"]>;
}

const ProductPageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <Layout.Root>
      <Layout.Header>
        <h1>
          {data?.brand?.company?.name} {data?.brand?.name} {data.flavor}
        </h1>
        <CheckIn />
      </Layout.Header>

      <Card.Container>
        {data.checkIns.nodes.map(({ id, author, rating }) => (
          <Card.Wrapper key={id}>
            <p>
              <b>{author && getDisplayName(author)}</b> has tasted{" "}
              <Link
                href={`/company/${data?.brand?.company?.name}/${data.id}`}
              >{`${data?.brand?.name} - ${data.flavor}`}</Link>{" "}
              by{" "}
              <Link href={`/company/${data?.brand?.company?.name}`}>
                {data?.brand?.company?.name}
              </Link>
            </p>
            {rating && <Stars rating={rating} />}
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

type CheckInForm = {
  review: string;
};

const CheckIn = () => {
  const [show, setShow] = React.useState(true);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CheckInForm>();

  const onSubmit = (value: CheckInForm) => {};

  return (
    <>
      <div onClick={() => setShow(!show)}>Check-in</div>
      {show && (
        <div>
          <Form onSubmit={handleSubmit(onSubmit)}>
            <Input
              id="review"
              autoComplete="review"
              placeholder="Review..."
              aria-invalid={errors.review ? "true" : "false"}
              css={{ width: "100%" }}
              {...register("review", {
                required: true,
                min: 2,
              })}
            />
            <StarSelector />
            <Button type="submit" css={{ width: "10rem" }}>
              Search
            </Button>
          </Form>
        </div>
      )}
    </>
  );
};

const Form = styled("form", {});

export default ProductPage;
