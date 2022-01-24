import {
  ActionFunction,
  Form,
  LoaderFunction,
  useActionData,
  useLoaderData,
  useTransition,
} from "remix";
import { SafeParseReturnType, z } from "zod";
import SDK, { sdk } from "~/api.server";
import { ErrorMessage } from "~/components/error-message";
import Input from "~/components/input";
import { Layout } from "~/components/layout";
import { Typography } from "~/components/typography";
import { styled } from "~/stitches.config";
import { getUser, getUserId } from "~/utils/session.server";

const codecs = {
  shortText: z.string().min(2).max(54),
};

const UserForm = z.object({
  username: z
    .string({
      required_error: "Username is required",
      invalid_type_error: "Username must be a string",
    })
    .min(2, { message: "Username must be at least 2 characters" })
    .max(24, { message: "Username can't be longer than 24 characters" })
    .regex(/^[a-zA-Z]([_]?[a-zA-Z0-9])+$/, {
      message: "Username can only contain letters from a-ZA-Z and numbers 0-9",
    }),
  firstName: codecs.shortText,
  lastName: codecs.shortText,
});

export const loader: LoaderFunction = async ({ request }) => {
  const user = await getUser(request);
  return user;
};

type SafeParseError = SafeParseReturnType<
  typeof UserForm,
  { username: string }
>;

export const action: ActionFunction = async ({
  request,
}): Promise<SafeParseError> => {
  const formData = await request.formData();
  const userId = await getUserId(request);

  const parsedUser = UserForm.safeParse({
    username: formData.get("username"),
    firstName: formData.get("firstName"),
    lastName: formData.get("lastName"),
  });

  if (parsedUser.success) {
    await sdk().updateUser({
      id: userId,
      ...parsedUser.data,
    });
  }

  return parsedUser;
};

const Errors = ({
  name,
  safeParseError,
}: {
  name: keyof z.infer<typeof UserForm>;
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

export default function Index() {
  const data = useLoaderData<SDK.GetUserByIdQuery>();
  const actionData = useActionData<SafeParseError>();
  const transition = useTransition();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>Edit profile</Typography.H1>
      </Layout.Header>
      <VerticalForm method="post">
        <label>
          Username
          <Input
            name="username"
            type="text"
            defaultValue={data.user.username}
          />
          <Errors name="username" safeParseError={actionData} />
        </label>
        <label>
          First Name
          <Input
            name="firstName"
            type="text"
            defaultValue={data.user.firstName}
          />
          <Errors name="username" safeParseError={actionData} />
        </label>
        <label>
          Last Name
          <Input
            name="lastName"
            type="text"
            defaultValue={data.user.lastName}
          />
          <Errors name="username" safeParseError={actionData} />
        </label>
        <button type="submit">
          {transition.submission ? "Saving..." : "Save"}
        </button>
      </VerticalForm>
    </Layout.Root>
  );
}

const VerticalForm = styled(Form, {
  display: "flex",
  flexDirection: "column",
  gap: "0.5rem",
});
