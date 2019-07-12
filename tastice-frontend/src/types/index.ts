export interface IProduct {
  name: string;
  producer: string;
  type: string;
  id: string;
}

export interface IProductProps {
  product: IProduct;
}
export interface IUser {
  firstName: string;
  lastName: string;
  email: string;
  id: string;
}

export interface IUserList {
  users: IUser[];
}

export interface IProductList {
  products: IProduct[];
}

export interface ILogIn {
  setToken: string;
}

export interface INavbar {
  setToken: string;
}

export interface IUserObject {
  user: IUser | null;
}

export interface INotificationContentWrapper {
  className?: string;
  message?: string;
  onClose?: () => void;
  variant: "success" | "warning" | "error" | "info";
}

export interface INotification {
  message: string;
  variant: any;
}

export interface INotificationObject {
  notification: INotification;
}
