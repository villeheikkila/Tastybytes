export interface Category {
    id: number;
    name: string;
  }
  
export interface Subcategory {
    id: number;
    name: string;
    categories: Category;
  }
  
  export interface BrandOwner {
    id: number;
    name: string;
  }
  
  export interface Brand {
    id: number;
    name: string;
    companies: BrandOwner;
  }
  
  export interface SubBrand {
    id: number;
    name: string;
    brands: Brand;
  }
  
  export interface Product {
    id: number;
    name: string;
    sub_brands: SubBrand;
    subcategories: Subcategory;
  }

  export interface Profile {
    id: string;
    username: string;
    avatar_url: string
  }