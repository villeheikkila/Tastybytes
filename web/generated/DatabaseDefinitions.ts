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
      migration_table: {
        Row: {
          id: number;
          category: string | null;
          subcategory: string | null;
          manufacturer: string | null;
          brand_owner: string | null;
          brand: string | null;
          "sub-brand": string | null;
          flavour: string | null;
          description: string | null;
          rating: string | null;
          location: string | null;
          image: string | null;
        };
        Insert: {
          id: number;
          category?: string | null;
          subcategory?: string | null;
          manufacturer?: string | null;
          brand_owner?: string | null;
          brand?: string | null;
          "sub-brand"?: string | null;
          flavour?: string | null;
          description?: string | null;
          rating?: string | null;
          location?: string | null;
          image?: string | null;
        };
        Update: {
          id?: number;
          category?: string | null;
          subcategory?: string | null;
          manufacturer?: string | null;
          brand_owner?: string | null;
          brand?: string | null;
          "sub-brand"?: string | null;
          flavour?: string | null;
          description?: string | null;
          rating?: string | null;
          location?: string | null;
          image?: string | null;
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
      products: {
        Row: {
          id: number;
          name: string;
          description: string | null;
          created_at: string;
          created_by: string | null;
          "sub-brand_id": number;
          manufacturer_id: number | null;
          migration_id: number | null;
          category_id: number;
        };
        Insert: {
          id?: number;
          name: string;
          description?: string | null;
          created_at?: string;
          created_by?: string | null;
          "sub-brand_id": number;
          manufacturer_id?: number | null;
          migration_id?: number | null;
          category_id: number;
        };
        Update: {
          id?: number;
          name?: string;
          description?: string | null;
          created_at?: string;
          created_by?: string | null;
          "sub-brand_id"?: number;
          manufacturer_id?: number | null;
          migration_id?: number | null;
          category_id?: number;
        };
      };
      brands: {
        Row: {
          id: number;
          name: string;
          brand_owner_id: number;
          created_at: string;
          created_by: string | null;
        };
        Insert: {
          id?: number;
          name: string;
          brand_owner_id: number;
          created_at?: string;
          created_by?: string | null;
        };
        Update: {
          id?: number;
          name?: string;
          brand_owner_id?: number;
          created_at?: string;
          created_by?: string | null;
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
          created_by: string | null;
        };
        Insert: {
          id?: number;
          name?: string | null;
          brand_id: number;
          created_at?: string;
          created_by?: string | null;
        };
        Update: {
          id?: number;
          name?: string | null;
          brand_id?: number;
          created_at?: string;
          created_by?: string | null;
        };
      };
      check_ins: {
        Row: {
          id: number;
          rating: number | null;
          review: string | null;
          created_at: string;
          created_by: string;
          product_id: number;
          migration_id: number | null;
          image_url: string | null;
        };
        Insert: {
          id?: number;
          rating?: number | null;
          review?: string | null;
          created_at?: string;
          created_by: string;
          product_id: number;
          migration_id?: number | null;
          image_url?: string | null;
        };
        Update: {
          id?: number;
          rating?: number | null;
          review?: string | null;
          created_at?: string;
          created_by?: string;
          product_id?: number;
          migration_id?: number | null;
          image_url?: string | null;
        };
      };
      profiles: {
        Row: {
          id: string;
          first_name: string | null;
          last_name: string | null;
          username: string;
          avatar_url: string | null;
        };
        Insert: {
          id: string;
          first_name?: string | null;
          last_name?: string | null;
          username: string;
          avatar_url?: string | null;
        };
        Update: {
          id?: string;
          first_name?: string | null;
          last_name?: string | null;
          username?: string;
          avatar_url?: string | null;
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
      subcategories: {
        Row: {
          id: number;
          name: string | null;
          created_at: string;
          created_by: string | null;
          category_id: number;
        };
        Insert: {
          id?: number;
          name?: string | null;
          created_at?: string;
          created_by?: string | null;
          category_id: number;
        };
        Update: {
          id?: number;
          name?: string | null;
          created_at?: string;
          created_by?: string | null;
          category_id?: number;
        };
      };
      products_subcategories: {
        Row: {
          product_id: number;
          subcategory_id: number;
          created_by: string | null;
          created_at: string;
        };
        Insert: {
          product_id?: number;
          subcategory_id: number;
          created_by?: string | null;
          created_at?: string;
        };
        Update: {
          product_id?: number;
          subcategory_id?: number;
          created_by?: string | null;
          created_at?: string;
        };
      };
      companies: {
        Row: {
          id: number;
          name: string;
          created_at: string;
          created_by: string | null;
        };
        Insert: {
          id?: number;
          name: string;
          created_at?: string;
          created_by?: string | null;
        };
        Update: {
          id?: number;
          name?: string;
          created_at?: string;
          created_by?: string | null;
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
    };
    Views: {
      csv_export: {
        Row: {
          category: string | null;
          subcategory: string | null;
          manufacturer: string | null;
          brand_owner: string | null;
          brand: string | null;
          "sub-brand": string | null;
          name: string | null;
          id: number | null;
          reviews: string | null;
          ratings: string | null;
          username: string | null;
        };
      };
    };
    Functions: {
      migrate_data: {
        Args: { IN: unknown };
        Returns: undefined;
      };
      delete_user: {
        Args: Record<PropertyKey, never>;
        Returns: undefined;
      };
      get_profile_summary: {
        Args: { uid: string };
        Returns: Record<string, unknown>[];
      };
    };
    Enums: {
      [_ in never]: never;
    };
  };
}

