import { Nullable } from "./types";
import { z } from "zod";

export const getDisplayName = ({
  firstName,
  lastName,
  username,
}: {firstName: Nullable<string>, lastName: Nullable<string>, username: string}) =>
  firstName && lastName ? `${firstName} ${lastName}` : username;


export const parseSlug = (s: unknown): string => z.string().parse(s);
