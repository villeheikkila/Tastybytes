import { Task } from "graphile-worker";

const taskList: Record<string, Task> = {
  hello: async (payload, helpers) => {
    helpers.logger.info(`Hello, ${(payload as any)?.name}`);
  },
};

export { taskList };
