-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard/project/daqluwqdavoqhvbhbbbm/sql)

-- 1. Customers table
create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text unique not null,
  address text not null,
  email text,
  credits numeric(10,2) default 0,
  created_at timestamptz default now()
);

-- 2. Credit transactions (audit trail)
create table if not exists credit_transactions (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id) on delete cascade,
  amount numeric(10,2) not null,
  type text check (type in ('topup','deduction')) not null,
  note text,
  created_at timestamptz default now()
);

-- 3. Delivery schedules (one row per customer per date)
create table if not exists delivery_schedules (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id) on delete cascade,
  delivery_date date not null,
  milk_type text not null,
  packets int not null default 1,
  status text check (status in ('scheduled','delivered','paused','cancelled')) default 'scheduled',
  cost numeric(10,2) not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(customer_id, delivery_date)
);

-- 4. Admin table (simple password-based)
create table if not exists admins (
  id uuid primary key default gen_random_uuid(),
  username text unique not null,
  password_hash text not null
);

-- Enable Row Level Security
alter table customers enable row level security;
alter table credit_transactions enable row level security;
alter table delivery_schedules enable row level security;
alter table admins enable row level security;

-- Allow anon to read/write customers (app handles auth via phone)
create policy "allow all on customers" on customers for all using (true) with check (true);
create policy "allow all on credit_transactions" on credit_transactions for all using (true) with check (true);
create policy "allow all on delivery_schedules" on delivery_schedules for all using (true) with check (true);
create policy "allow all on admins" on admins for all using (true) with check (true);

-- Insert default admin (username: admin, password: nandini2024)
-- Password is stored as plain text here for simplicity — change after setup!
insert into admins (username, password_hash) values ('admin', 'Appu@2014')
on conflict (username) do nothing;
