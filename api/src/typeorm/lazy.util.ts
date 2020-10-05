// eslint-disable-next-line @typescript-eslint/ban-types
export type Lazy<T extends object> = Promise<T> | T;
