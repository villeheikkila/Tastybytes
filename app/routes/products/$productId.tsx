import { StatusCodes } from "http-status-codes";
import {
  ActionFunction,
  Form,
  Link,
  LoaderFunction,
  Outlet,
  useActionData,
  useLoaderData,
  useTransition,
} from "remix";
import { z } from "zod";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { ErrorMessage } from "~/components/error-message";
import Input from "~/components/input";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { styled } from "~/stitches.config";
import Codecs from "~/utils/codecs";
import FormUtils from "~/utils/form-utils";
import { paths } from "~/utils/paths";
import { getUserId } from "~/utils/session.server";

interface LoaderResult {
  product: SDK.GetProductByIdQuery["product"];
  isLoggedIn: boolean;
}

export const loader: LoaderFunction = async ({
  request,
  params,
}): Promise<LoaderResult> => {
  if (!params.productId) {
    throw new Response("Not found.", { status: 404 });
  }

  const userId = await getUserId(request);

  const productId = parseInt(params.productId, 10);
  const data = await sdk().getProductById({ productId });
  return { product: data.product, isLoggedIn: !!userId };
};

const CheckInForm = z.object({
  review: Codecs.review,
  rating: Codecs.rating,
});

type SafeParseError = z.SafeParseReturnType<
  typeof CheckInForm,
  { review?: string; rating?: number }
>;

export const action: ActionFunction = async ({
  request,
  params,
}): Promise<SafeParseError> => {
  if (!params.productId) {
    throw new Response("Not found.", { status: StatusCodes.NOT_FOUND });
  }

  const formData = await request.formData();
  const userId = await getUserId(request);

  if (!userId) {
    throw new Response("You need to be logged in to create a check in.", {
      status: StatusCodes.UNAUTHORIZED,
    });
  }

  const productId = parseInt(params.productId, 10);

  const parsedCheckIn = FormUtils.parseValuesFromFormData(
    CheckInForm.partial(),
    formData,
    "review",
    "rating"
  );

  if (parsedCheckIn.success) {
    await sdk().createCheckIn({
      authorId: userId,
      productId: productId,
      ...parsedCheckIn.data,
    });
  }

  return parsedCheckIn;
};

export default function Index() {
  const { product, isLoggedIn } = useLoaderData<LoaderResult>();
  const actionData = useActionData<SafeParseError>();
  const transition = useTransition();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>
          {product?.brand?.company?.name} {product?.brand?.name} {product?.name}
        </Typography.H1>
      </Layout.Header>

      {isLoggedIn && (
        <VerticalForm method="post">
          <label>
            Review
            <Input name="review" type="text" />
            <Errors name="review" safeParseError={actionData} />
          </label>
          <label>
            Rating
            <Input name="rating" type="number" />
            <Errors name="rating" safeParseError={actionData} />
          </label>
          <button type="submit">
            {transition.submission ? "Saving..." : "Save"}
          </button>
        </VerticalForm>
      )}

      <Card.Container>
        {product?.checkIns.nodes.map(({ id, author, rating }) => (
          <Card.Wrapper key={id}>
            <p>
              <Link to={paths.user(author?.username ?? "")}>
                <b>{author?.username}</b>
              </Link>{" "}
              has tasted{" "}
              <Link
                to={paths.products(id)}
              >{`${product?.brand?.name} - ${product?.name}`}</Link>{" "}
              by{" "}
              <Link to={paths.company(product?.brand?.company?.id ?? 0)}>
                {product?.brand?.company?.name}
              </Link>
            </p>
            {rating && <Stars rating={rating} />}
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
}

const Errors = ({
  name,
  safeParseError,
}: {
  name: keyof z.infer<typeof CheckInForm>;
  safeParseError?: SafeParseError;
}) => {
  if (!safeParseError || safeParseError.success) return null;

  const errors = safeParseError.error.issues.filter(({ path }) =>
    path.includes(name)
  );

  return (
    <ErrorContainer>
      {errors.map((error) => (
        <ErrorMessage key={error.message}>{error.message}</ErrorMessage>
      ))}
    </ErrorContainer>
  );
};

const ErrorContainer = styled("div", {
  display: "flex",
  flexDirection: "column",
});

const VerticalForm = styled(Form, {
  display: "flex",
  flexDirection: "column",
  gap: "0.5rem",
});
