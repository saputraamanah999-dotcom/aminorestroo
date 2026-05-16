create extension if not exists "pgcrypto";

create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade, email text unique, full_name text, phone text, avatar_url text, role text not null default 'customer' check (role in ('customer','admin')), created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.categories (id uuid primary key default gen_random_uuid(), name text not null, slug text not null unique, sort_order int default 0, is_active boolean default true, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.menu_items (id uuid primary key default gen_random_uuid(), category_id uuid references public.categories(id) on delete set null, name text not null, description text, price integer not null default 0, image_url text, dietary_label text, is_available boolean default true, is_featured boolean default false, is_recommended boolean default false, is_best_seller boolean default false, is_new boolean default false, sort_order int default 0, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.item_variants (id uuid primary key default gen_random_uuid(), menu_item_id uuid not null references public.menu_items(id) on delete cascade, name text not null, price integer not null, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.orders (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade, status text default 'pending', order_type text default 'dine_in', customer_name text, customer_phone text, table_number text, delivery_address text, delivery_lat numeric, delivery_lng numeric, payment_method text default 'Cash', notes text, subtotal integer default 0, tax integer default 0, service_fee integer default 0, total integer default 0, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.order_items (id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade, menu_item_id uuid references public.menu_items(id) on delete set null, item_name text not null, variant_name text, note text, quantity integer not null check(quantity > 0), unit_price integer not null, total_price integer not null, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.bookings (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete set null, booking_date date not null, booking_time time not null, party_size integer not null check(party_size > 0), status text default 'pending', notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.reviews (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id), menu_item_id uuid references public.menu_items(id), order_id uuid references public.orders(id), rating int check (rating between 1 and 5), comment text, reply text, reply_by uuid references public.profiles(id), reply_at timestamptz, is_verified boolean default false, is_visible boolean default true, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.restaurant_settings (id uuid primary key default gen_random_uuid(), restaurant_name text default 'Amino Resto Bali', address text default 'Uluwatu St No.77, Ungasan, Bali', announcement text, opening_hours text, breakfast_hours text, lunch_dinner_hours text, open_status boolean default true, rating_average numeric default 4.9, whatsapp text, maps_url text, maps_embed_url text, gojek_url text, grabfood_url text, logo_url text, hero_image_url text, qris_image_url text, tax_rate numeric default 0.10, service_rate numeric default 0.05, primary_color text, accent_color text, email_notifications boolean default true, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.gallery (id uuid primary key default gen_random_uuid(), title text, category text, image_url text, is_visible boolean default true, sort_order int default 0, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.promos (id uuid primary key default gen_random_uuid(), title text not null, description text, code text unique, discount_percent int default 0, is_active boolean default true, starts_at timestamptz, ends_at timestamptz, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.notifications (id uuid primary key default gen_random_uuid(), type text not null, recipient text, subject text, status text default 'pending', payload jsonb default '{}'::jsonb, error text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.loyalty_logs (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade, points int not null default 0, reason text, created_at timestamptz default now(), updated_at timestamptz default now());

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin')
$$;

create table if not exists public.activity_logs (id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id) on delete set null, action text not null, entity text, entity_id uuid, metadata jsonb default '{}'::jsonb, created_at timestamptz default now(), updated_at timestamptz default now());

alter table public.reviews enable row level security;
do $$ begin
  create policy "public select visible reviews" on public.reviews for select using (is_visible = true or public.is_admin());
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "users insert own reviews" on public.reviews for insert to authenticated with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "users update own unreplied reviews" on public.reviews for update to authenticated using (auth.uid() = user_id and reply is null) with check (auth.uid() = user_id and reply is null);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "users delete own unreplied reviews" on public.reviews for delete to authenticated using (auth.uid() = user_id and reply is null);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "admins manage reviews" on public.reviews for all to authenticated using (public.is_admin()) with check (public.is_admin());
exception when duplicate_object then null; end $$;

alter table public.menu_items add column if not exists is_recommended boolean default false;
alter table public.menu_items add column if not exists is_best_seller boolean default false;
alter table public.menu_items add column if not exists is_new boolean default false;
alter table public.orders add column if not exists customer_name text;
alter table public.orders add column if not exists customer_phone text;
alter table public.orders add column if not exists table_number text;
alter table public.orders add column if not exists delivery_address text;
alter table public.orders add column if not exists delivery_lat numeric;
alter table public.orders add column if not exists delivery_lng numeric;
alter table public.orders add column if not exists payment_method text default 'Cash';
alter table public.order_items add column if not exists note text;
alter table public.reviews add column if not exists menu_item_id uuid references public.menu_items(id);
alter table public.reviews add column if not exists order_id uuid references public.orders(id);
alter table public.reviews add column if not exists reply text;
alter table public.reviews add column if not exists admin_reply text;
alter table public.reviews add column if not exists reply_by uuid references public.profiles(id);
alter table public.reviews add column if not exists reply_at timestamptz;
alter table public.reviews add column if not exists is_verified boolean default false;
alter table public.reviews add column if not exists is_visible boolean default true;
alter table public.restaurant_settings add column if not exists restaurant_name text default 'Amino Resto Bali';
alter table public.restaurant_settings add column if not exists address text default 'Uluwatu St No.77, Ungasan, Bali';
alter table public.restaurant_settings add column if not exists breakfast_hours text;
alter table public.restaurant_settings add column if not exists lunch_dinner_hours text;
alter table public.restaurant_settings add column if not exists open_status boolean default true;
alter table public.restaurant_settings add column if not exists maps_embed_url text;
alter table public.restaurant_settings add column if not exists logo_url text;
alter table public.restaurant_settings add column if not exists hero_image_url text;
alter table public.restaurant_settings add column if not exists qris_image_url text;
alter table public.restaurant_settings add column if not exists tax_rate numeric default 0.10;
alter table public.restaurant_settings add column if not exists service_rate numeric default 0.05;
alter table public.restaurant_settings add column if not exists primary_color text;
alter table public.restaurant_settings add column if not exists accent_color text;
alter table public.restaurant_settings add column if not exists email_notifications boolean default true;
alter table public.gallery add column if not exists category text;
