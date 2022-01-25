import { z } from "zod";

const parseValuesFromFormData = <
  T extends z.ZodRawShape,
  K extends keyof T & string
>(
  parser: z.ZodObject<T>,
  formData: FormData,
  ...args: K[]
) => {
  const formDataGetters = args.reduce(
    (previous, current) => ({ ...previous, [current]: formData.get(current) }),
    {}
  );
  return parser.safeParse(formDataGetters);
};

const FormUtils = {
    parseValuesFromFormData
}

export default FormUtils