import { ProductJoined } from "../api/products";

export const constructProductName = (p: ProductJoined) =>
  [p["sub-brands"].brands.name, p["sub-brands"].name, p.name]
    .flatMap((p) => (p === undefined || p === null || p === "" ? [] : p))
    .join(" ");
