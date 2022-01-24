export const getDisplayName = ({
    firstName,
    lastName,
    username,
  }: {firstName: Nullable<string>, lastName: Nullable<string>, username: string}) =>
    firstName && lastName ? `${firstName} ${lastName}` : username;

    export type Nullable<T> = T | None;
    export type None = null | undefined;
