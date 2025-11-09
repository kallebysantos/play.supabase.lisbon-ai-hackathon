create table hackathons (
  id uuid not null primary key default uuid_generate_v4(),
  url text unique,
  name text,
  host_company text not null,
  description text,
  sponsors text[],
  location text,
  start_date timestamptz,
  end_date timestamptz,
  -- System fields
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

