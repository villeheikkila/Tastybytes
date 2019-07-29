/// <reference types="react-scripts" />

interface Product {
    id: string;
    name: string;
    company: any;
    category: any;
    subCategory: any;
}

interface ProductObject {
    product: Product;
    showMenu: boolean;
}

interface User {
    firstName: string;
    lastName: string;
    email: string;
    id: string;
}

interface UserList {
    users: User[];
}

interface ProductList {
    products: Product[];
}

interface Token {
    setToken: any;
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

interface SubCategory {
    id: string;
    name: string;
}
interface Category {
    id: string;
    name: string;
    subCategory: SubCategory[];
}

interface NameId {
    name: string;
    id: string;
}
