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
      friends: {
        Row: {
          id: number;
          user_id_1: string;
          user_id_2: string;
          status: Database["public"]["Enums"]["friend_status"];
          accepted_at: string | null;
          blocked_by: string | null;
          created_at: string;
        };
        Insert: {
          id?: number;
          user_id_1: string;
          user_id_2: string;
          status?: Database["public"]["Enums"]["friend_status"];
          accepted_at?: string | null;
          blocked_by?: string | null;
          created_at?: string;
        };
        Update: {
          id?: number;
          user_id_1?: string;
          user_id_2?: string;
          status?: Database["public"]["Enums"]["friend_status"];
          accepted_at?: string | null;
          blocked_by?: string | null;
          created_at?: string;
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
          fts: unknown | null;
          color_scheme: Database["public"]["Enums"]["color_scheme"];
        };
        Insert: {
          id: string;
          first_name?: string | null;
          last_name?: string | null;
          username: string;
          avatar_url?: string | null;
          fts?: unknown | null;
          color_scheme?: Database["public"]["Enums"]["color_scheme"];
        };
        Update: {
          id?: string;
          first_name?: string | null;
          last_name?: string | null;
          username?: string;
          avatar_url?: string | null;
          fts?: unknown | null;
          color_scheme?: Database["public"]["Enums"]["color_scheme"];
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
      accept_friend_request: {
        Args: { user_id: string };
        Returns: undefined;
      };
      get_friends_by_username: {
        Args: { p_username: string };
        Returns: unknown;
      };
      get_activity_feed: {
        Args: Record<PropertyKey, never>;
        Returns: unknown;
      };
      set_limit: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      show_limit: {
        Args: Record<PropertyKey, never>;
        Returns: number;
      };
      show_trgm: {
        Args: Record<string, unknown>;
        Returns: string[];
      };
      similarity: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      similarity_op: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      word_similarity: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      word_similarity_op: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      word_similarity_commutator_op: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      similarity_dist: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      word_similarity_dist_op: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      word_similarity_dist_commutator_op: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      gtrgm_in: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_out: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_consistent: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      gtrgm_distance: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      gtrgm_compress: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_decompress: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_penalty: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_picksplit: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_union: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gtrgm_same: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gin_extract_value_trgm: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gin_extract_query_trgm: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      gin_trgm_consistent: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      gin_trgm_triconsistent: {
        Args: Record<string, unknown>;
        Returns: unknown;
      };
      strict_word_similarity: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      strict_word_similarity_op: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      strict_word_similarity_commutator_op: {
        Args: Record<string, unknown>;
        Returns: boolean;
      };
      strict_word_similarity_dist_op: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      strict_word_similarity_dist_commutator_op: {
        Args: Record<string, unknown>;
        Returns: number;
      };
      gtrgm_options: {
        Args: Record<string, unknown>;
        Returns: undefined;
      };
      search_products: {
        Args: { p_search_term: string };
        Returns: unknown;
      };
    };
    Enums: {
      friend_status: "accepted" | "pending" | "blocked";
      color_scheme: "light" | "dark" | "system";
    };
  };
}

