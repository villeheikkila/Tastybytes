export const paths = {
    user: (username: string) => `/users/${username}`,
    company: (name: number) => `/companies/${name}`,
    products: (productId: number) => `/products/${productId}`,
    settings: "/settings",
    logout: "/logout"
}