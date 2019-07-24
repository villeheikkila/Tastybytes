export interface Product {
    id: string;
    name: string;
    producer: string;
    category: any;
    subCategory: any;
}

export interface ProductObject {
    product: Product;
    showMenu: boolean;
}

export interface User {
    firstName: string;
    lastName: string;
    email: string;
    id: string;
}

export interface UserList {
    users: User[];
}

export interface ProductList {
    products: Product[];
}

export interface Token {
    setToken: any;
}

export interface UserObject {
    user: User | null;
}

export interface NotificationProps {
    className?: string;
    message?: string;
    onClose?: () => void;
    variant: 'success' | 'warning' | 'error' | 'info';
}

export interface Notification {
    message: string;
    variant: any;
}

export interface NotificationObject {
    notification: Notification;
}

export interface OptionType {
    label: string;
    value: string;
}

export interface ConfirmationDialogProps {
    content: string;
    title: string;
    description: string;
    declineButton: string;
    acceptButton: string;
    visible: boolean;
    setVisible: any;
    onAccept: any;
}

export interface CreateCheckInProps {
    authorId: string;
    productId: string;
}
