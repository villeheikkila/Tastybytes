export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json }
  | Json[];

export interface Database {
  public: {
    Tables: {
      products: {
        Row: {
          name: string;
          description: string | null;
          created_at: string;
          created_by: string;
          id: number;
          "sub-brand_id": number;
          subcategory_id: number;
          manufacturer_id: number | null;
        };
        Insert: {
          name: string;
          description?: string | null;
          created_at?: string;
          created_by: string;
          id?: number;
          "sub-brand_id": number;
          subcategory_id: number;
          manufacturer_id?: number | null;
        };
        Update: {
          name?: string;
          description?: string | null;
          created_at?: string;
          created_by?: string;
          id?: number;
          "sub-brand_id"?: number;
          subcategory_id?: number;
          manufacturer_id?: number | null;
        };
      };
      check_in_reactions: {
        Row: {
          id: number;
          created_at: string | null;
          created_by: string | null;
          reaction_id: number;
          check_in_id: number | null;
        };
        Insert: {
          id?: number;
          created_at?: string | null;
          created_by?: string | null;
          reaction_id: number;
          check_in_id?: number | null;
        };
        Update: {
          id?: number;
          created_at?: string | null;
          created_by?: string | null;
          reaction_id?: number;
          check_in_id?: number | null;
        };
      };
      brands: {
        Row: {
          id: number;
          name: string;
          brand_owner_id: number;
          created_at: string;
          created_by: string;
        };
        Insert: {
          id?: number;
          name: string;
          brand_owner_id: number;
          created_at: string;
          created_by: string;
        };
        Update: {
          id?: number;
          name?: string;
          brand_owner_id?: number;
          created_at?: string;
          created_by?: string;
        };
      };
      reactions: {
        Row: {
          id: number;
          name: string;
        };
        Insert: {
          id?: number;
          name: string;
        };
        Update: {
          id?: number;
          name?: string;
        };
      };
      "sub-brands": {
        Row: {
          id: number;
          name: string | null;
          brand_id: number;
          created_at: string;
          created_by: string;
        };
        Insert: {
          id?: number;
          name?: string | null;
          brand_id: number;
          created_at?: string;
          created_by: string;
        };
        Update: {
          id?: number;
          name?: string | null;
          brand_id?: number;
          created_at?: string;
          created_by?: string;
        };
      };
      check_ins: {
        Row: {
          id: number;
          rating: string | null;
          review: string | null;
          created_at: string;
          created_by: string;
          product_id: number;
        };
        Insert: {
          id?: number;
          rating?: string | null;
          review?: string | null;
          created_at?: string;
          created_by: string;
          product_id: number;
        };
        Update: {
          id?: number;
          rating?: string | null;
          review?: string | null;
          created_at?: string;
          created_by?: string;
          product_id?: number;
        };
      };
      profiles: {
        Row: {
          id: string;
          first_name: string | null;
          last_name: string | null;
          username: string;
        };
        Insert: {
          id: string;
          first_name?: string | null;
          last_name?: string | null;
          username: string;
        };
        Update: {
          id?: string;
          first_name?: string | null;
          last_name?: string | null;
          username?: string;
        };
      };
      subcategories: {
        Row: {
          id: number;
          name: string | null;
          created_at: string;
          created_by: string;
        };
        Insert: {
          id?: number;
          name?: string | null;
          created_at?: string;
          created_by: string;
        };
        Update: {
          id?: number;
          name?: string | null;
          created_at?: string;
          created_by?: string;
        };
      };
      check_in_comments: {
        Row: {
          id: number;
          content: string;
          created_at: string;
          created_by: string;
          check_in_id: number;
        };
        Insert: {
          id?: number;
          content: string;
          created_at?: string;
          created_by: string;
          check_in_id: number;
        };
        Update: {
          id?: number;
          content?: string;
          created_at?: string;
          created_by?: string;
          check_in_id?: number;
        };
      };
      categories: {
        Row: {
          id: number;
          name: string;
        };
        Insert: {
          id?: number;
          name: string;
        };
        Update: {
          id?: number;
          name?: string;
        };
      };
      companies: {
        Row: {
          name: string | null;
          id: number;
          created_at: string;
          created_by: string;
        };
        Insert: {
          name?: string | null;
          id?: number;
          created_at?: string;
          created_by: string;
        };
        Update: {
          name?: string | null;
          id?: number;
          created_at?: string;
          created_by?: string;
        };
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      [_ in never]: never;
    };
  };
}

