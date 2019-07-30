/// <reference types="react-scripts" />

interface Product {
    id: string;
    name: string;
    company: [NameId];
    category: [NameId];
    subCategory: [NameId];
}

interface User {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
    admin: boolean;
}

interface UserList {
    users: User[];
}

interface ProductList {
    products: Product[];
}

interface Token {
    setToken: React.Dispatch<string | null>;
}

interface UserObject {
    user: User | null;
}

interface NotificationContent {
    message: string;
    variant: any;
}

interface NotificationObject {
    notification: Notification;
}

interface OptionType {
    label: string;
    value: string;
}

interface Suggestions {
    value: string;
    label: string;
    id: string;
}

interface Category {
    id: string;
    name: string;
    subCategory: NameId[];
}

interface NameId {
    name: string;
    id: string;
}

interface SimpleUserObject {
    id: string;
    firstName: string;
    lastName: string;
}

interface IdObject {
    id: string;
}

interface ProductObject {
    name: string;
    id: string;
    category: [NameId];
    subCategory: [NameId];
    company: [NameId];
}

interface CheckInObject {
    id: string;
    rating: number;
    comment: string;
    createdAt: Date;
    author: SimpleUserObject;
    product: ProductObject;
}

interface FriendRequestObject {
    id: string;
    receiver: SimpleUserObject;
    sender: [SimpleUserObject];
}
