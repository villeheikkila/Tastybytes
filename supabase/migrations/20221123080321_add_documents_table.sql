create table "public"."documents" (
    "page_name" text not null,
    "document" jsonb
);


CREATE UNIQUE INDEX documents_pkey ON public.documents USING btree (page_name);

alter table "public"."documents" add constraint "documents_pkey" PRIMARY KEY using index "documents_pkey";