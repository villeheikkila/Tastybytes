/// <reference types="react-scripts" />

interface Product {
    id: string;
    name: string;
    company: NameId;
    imageId: string;
    category: [Category];
    subCategory: [NameId];
}

interface User {
    id: string;
    firstName: string;
    lastName: string;
    avatarId: string;
    avatarColor: string;
    email: string;
    admin: boolean;
}

interface Suggestions {
    value: string;
    label: string;
    id: string;
}

interface Definition {
    kind: string;
    operation?: string;
}

interface Category {
    id: string;
    name: string;
    color: string;
    subCategory?: NameId[];
}

interface NameId {
    name: string;
    id: string;
}

interface IdObject {
    id: string;
}

interface CheckInObject {
    id: string;
    rating: number;
    comment: string;
    createdAt: Date;
    author: User;
    product: Product;
    image: string;
}

interface FriendRequestObject {
    id: string;
    receiver: [User];
    sender: [User];
    message: string;
}

interface LocalStorageUser {
    token: string | undefined;
    id: string;
    admin: boolean;
}
