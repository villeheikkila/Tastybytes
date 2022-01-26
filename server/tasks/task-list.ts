import { Task } from "graphile-worker";
import { confirm_email } from "./confirm-email";
import { reset_password } from "./reset-password";

const taskList: Record<string, Task> = {
  confirm_email,
  reset_password,
};

export { taskList };
