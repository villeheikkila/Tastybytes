export const paths = {
    user: (username: string) => `/users/${username}`,
    company: (name: string) => `/company/${name}`,
    products: (productId: number) => `/products/${productId}`
}