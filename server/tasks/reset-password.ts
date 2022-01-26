import { sendMail } from "../mailer";
import { getTemplate } from "../mailer/templates";
import { Task } from "graphile-worker";
import { z } from "zod";

const ResetPasswordPayload = z.object({
  email: z.string().email(),
  token: z.string(),
});

export const reset_password: Task = async (payload) => {
  const parsedPayload = ResetPasswordPayload.parse(payload);
  await sendMail({
    to: parsedPayload.email,
    ...getTemplate("reset_password")({ token: parsedPayload.token }),
  });
};
