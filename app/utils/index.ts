import type { Product } from "~/types/custom";

export const paths = {
    user: (username: string) => `/users/${username}`,
    settings: "/settings",
    logout: "/logout",
    signUp: "/sign-up",
    product: (product: Product) => {
        return `/products/${product.subcategories.categories.name}/${product.subcategories.name}/${product.sub_brands.brands.companies.name}/${product.sub_brands.brands.name}/${product.sub_brands.name}/${product.name}`;
      }
}