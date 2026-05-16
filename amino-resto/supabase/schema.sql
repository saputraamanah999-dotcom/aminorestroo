create extension if not exists "pgcrypto";

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  phone text,
  avatar_url text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin')
$$;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id,email,full_name,role)
  values (new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)),'customer')
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

create table public.categories (id uuid primary key default gen_random_uuid(), name text not null, slug text not null unique, sort_order int default 0, is_active boolean default true, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.menu_items (id uuid primary key default gen_random_uuid(), category_id uuid references public.categories(id) on delete set null, name text not null, description text, price integer not null default 0, image_url text, dietary_label text, is_available boolean default true, is_featured boolean default false, sort_order int default 0, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.item_variants (id uuid primary key default gen_random_uuid(), menu_item_id uuid not null references public.menu_items(id) on delete cascade, name text not null, price integer not null, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.orders (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade, status text default 'pending' check (status in ('pending','confirmed','preparing','ready','completed','cancelled')), order_type text default 'dine_in', notes text, subtotal integer default 0, tax integer default 0, service_fee integer default 0, total integer default 0, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.order_items (id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade, menu_item_id uuid references public.menu_items(id) on delete set null, item_name text not null, variant_name text, quantity integer not null check(quantity > 0), unit_price integer not null, total_price integer not null, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.bookings (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete set null, booking_date date not null, booking_time time not null, party_size integer not null check(party_size > 0), status text default 'pending' check(status in ('pending','confirmed','completed','cancelled')), notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.reviews (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete set null, rating int not null check(rating between 1 and 5), comment text not null, admin_reply text, is_visible boolean default true, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.restaurant_settings (id uuid primary key default gen_random_uuid(), announcement text default 'Welcome to Amino Resto. PRICES ARE NOT FIXED. Tax 10% and service 5% apply.', opening_hours text default 'Open daily 10:00 - 22:00', rating_average numeric default 4.9, whatsapp text, maps_url text, gojek_url text, grabfood_url text, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.gallery (id uuid primary key default gen_random_uuid(), title text, image_url text, is_visible boolean default true, sort_order int default 0, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.promos (id uuid primary key default gen_random_uuid(), title text not null, description text, code text unique, discount_percent int default 0, is_active boolean default true, starts_at timestamptz, ends_at timestamptz, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.notifications (id uuid primary key default gen_random_uuid(), type text not null, recipient text, subject text, status text default 'pending', payload jsonb default '{}'::jsonb, error text, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.loyalty_logs (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade, points int not null default 0, reason text, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.activity_logs (id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id) on delete set null, action text not null, entity text, entity_id uuid, metadata jsonb default '{}'::jsonb, created_at timestamptz default now(), updated_at timestamptz default now());

create index on public.menu_items(category_id); create index on public.orders(user_id); create index on public.order_items(order_id); create index on public.bookings(user_id); create index on public.reviews(user_id);

do $$ declare r record; begin for r in select tablename from pg_tables where schemaname='public' and tablename in ('profiles','categories','menu_items','item_variants','orders','order_items','bookings','reviews','restaurant_settings','gallery','promos','notifications','loyalty_logs','activity_logs') loop execute format('drop trigger if exists set_%I_updated_at on public.%I', r.tablename, r.tablename); execute format('create trigger set_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()', r.tablename, r.tablename); end loop; end $$;
