INSERT INTO "public"."permissions" ("id", "name")
    VALUES (1, 'can_delete_products'), (2, 'can_delete_companies'), (3, 'can_delete_brands'), (4, 'can_add_subcategories'), (5, 'can_merge_products'), (6, 'can_edit_companies'), (7, 'can_verify'), (8, 'can_edit_brands'), (9, 'can_insert_flavors'), (10, 'can_update_flavors'), (11, 'can_delete_flavors'), (12, 'can_update_sub_brands'), (13, 'can_create_check_ins'), (14, 'can_create_products'), (15, 'can_create_brands'), (16, 'can_send_friend_requests'), (17, 'can_react_to_check_ins'), (18, 'can_create_companies'), (19, 'can_edit_products');

INSERT INTO roles ("id", "name")
    VALUES (1, 'admin'), (2, 'user');

INSERT INTO "public"."roles_permissions" ("role_id", "permission_id")
    VALUES (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (2, 13), (2, 14), (2, 15), (2, 16), (2, 17), (1, 18), (2, 18);

INSERT INTO documents (page_name, document)
    VALUES ('about', jsonb_build_object('summary', 'TasteNotes was born out of passion for tasting food and it tries to fill the void space between various other tracking apps', 'github_url', 'https://github.com/villeheikkila/TasteNotes', 'linked_in_url', 'www.linkedin.com/in/heikkilaville', 'portfolio_url', 'https://villeheikkila.com'));

