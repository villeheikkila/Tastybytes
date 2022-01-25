import { z } from "zod";

const Codecs = {
    shortText: z.string().min(2).max(54),
    rating: z.preprocess(
        (a) => {
            const parsed = parseInt(a as string, 10)
            return isNaN(parsed) ? undefined : parsed
        },
        z.number().positive().min(0).max(10)
      ),
    review: z.string().min(1).max(1024)
};

export default Codecs