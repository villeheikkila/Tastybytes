export type None = null | undefined;

export type Nullable<T> = T | None;

export type NonNullable<T> = Exclude<T, null | undefined>;
