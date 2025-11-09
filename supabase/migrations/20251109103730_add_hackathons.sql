create table "public"."hackathons" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "url" text not null unique,
    "name" text,
    "host_company" text not null,
    "description" text,
    "sponsors" text[],
    "location" text,
    "start_date" timestamp with time zone,
    "end_date" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone
      );


CREATE UNIQUE INDEX hackathons_pkey ON public.hackathons USING btree (id);

alter table "public"."hackathons" add constraint "hackathons_pkey" PRIMARY KEY using index "hackathons_pkey";

grant delete on table "public"."hackathons" to "anon";

grant insert on table "public"."hackathons" to "anon";

grant references on table "public"."hackathons" to "anon";

grant select on table "public"."hackathons" to "anon";

grant trigger on table "public"."hackathons" to "anon";

grant truncate on table "public"."hackathons" to "anon";

grant update on table "public"."hackathons" to "anon";

grant delete on table "public"."hackathons" to "authenticated";

grant insert on table "public"."hackathons" to "authenticated";

grant references on table "public"."hackathons" to "authenticated";

grant select on table "public"."hackathons" to "authenticated";

grant trigger on table "public"."hackathons" to "authenticated";

grant truncate on table "public"."hackathons" to "authenticated";

grant update on table "public"."hackathons" to "authenticated";

grant delete on table "public"."hackathons" to "service_role";

grant insert on table "public"."hackathons" to "service_role";

grant references on table "public"."hackathons" to "service_role";

grant select on table "public"."hackathons" to "service_role";

grant trigger on table "public"."hackathons" to "service_role";

grant truncate on table "public"."hackathons" to "service_role";

grant update on table "public"."hackathons" to "service_role";


