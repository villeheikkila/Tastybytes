const userBase = "/users";

const createUrl = (...parts: string[]) => parts.join("/");

export const paths = {
  activity: "/",
  settings: "/settings",
  search: "/search",
  user: {
    root: (username: string) => createUrl(userBase, username),
    friends: (username: string) => createUrl(userBase, username, "friends"),
  },
};
