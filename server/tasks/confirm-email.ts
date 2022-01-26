import { sendMail } from "../mailer";
import { getTemplate } from "../mailer/templates";
import { Task } from "graphile-worker";
import { z } from "zod";

const ConfirmEmailPayload = z.object({
  email: z.string().email(),
  token: z.string(),
});

export const confirm_email: Task = async (payload) => {
  const parsedPayload = ConfirmEmailPayload.parse(payload);

  await sendMail({
    to: parsedPayload.email,
    ...getTemplate("confirm_email")({ token: parsedPayload.token }),
  });
};
