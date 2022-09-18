const userBase = "/users";
const productBase = "/products";

const createUrl = (...parts: (string | number)[]) => parts.join("/");

export const paths = {
  activity: "/",
  settings: "/settings",
  search: "/search",
  user: {
    root: (username: string) => createUrl(userBase, username),
    friends: (username: string) => createUrl(userBase, username, "friends"),
  },
  products: {
    root: (productId: number) => createUrl(productBase, productId),
  },
};
