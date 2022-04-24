import type { Product } from "~/types/custom";

export const paths = {
    user: (id: string) => `/users/${id}`,
    settings: "/settings",
    logout: "/logout",
    signUp: "/sign-up",
    login: "/login",
    product: (product: Product) => {
        return `/products/${product.subcategories.categories.name}/${product.subcategories.name}/${product.sub_brands.brands.companies.name}/${product.sub_brands.brands.name}/${product.sub_brands.name}/${product.name}`;
      }
}