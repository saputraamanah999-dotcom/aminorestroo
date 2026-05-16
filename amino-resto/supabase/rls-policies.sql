alter table public.profiles enable row level security; alter table public.categories enable row level security; alter table public.menu_items enable row level security; alter table public.item_variants enable row level security; alter table public.orders enable row level security; alter table public.order_items enable row level security; alter table public.bookings enable row level security; alter table public.reviews enable row level security; alter table public.restaurant_settings enable row level security; alter table public.gallery enable row level security; alter table public.promos enable row level security; alter table public.notifications enable row level security; alter table public.loyalty_logs enable row level security; alter table public.activity_logs enable row level security;

create policy "profiles own read" on public.profiles for select using (auth.uid() = id or public.is_admin());
create policy "profiles own update" on public.profiles for update using (auth.uid() = id or public.is_admin()) with check (auth.uid() = id or public.is_admin());

create policy "public read categories" on public.categories for select using (is_active or public.is_admin());
create policy "admin write categories" on public.categories for all using (public.is_admin()) with check (public.is_admin());
create policy "public read menu" on public.menu_items for select using (is_available or public.is_admin());
create policy "admin write menu" on public.menu_items for all using (public.is_admin()) with check (public.is_admin());
create policy "public read variants" on public.item_variants for select using (exists(select 1 from public.menu_items m where m.id = menu_item_id and (m.is_available or public.is_admin())));
create policy "admin write variants" on public.item_variants for all using (public.is_admin()) with check (public.is_admin());

create policy "customers create orders" on public.orders for insert with check (auth.uid() = user_id);
create policy "customers read own orders" on public.orders for select using (auth.uid() = user_id or public.is_admin());
create policy "admin update orders" on public.orders for update using (public.is_admin()) with check (public.is_admin());
create policy "customers create order items" on public.order_items for insert with check (exists(select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
create policy "read own order items" on public.order_items for select using (exists(select 1 from public.orders o where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));
create policy "admin order items" on public.order_items for all using (public.is_admin()) with check (public.is_admin());

create policy "customers create bookings" on public.bookings for insert with check (auth.uid() = user_id);
create policy "read own bookings" on public.bookings for select using (auth.uid() = user_id or public.is_admin());
create policy "admin update bookings" on public.bookings for update using (public.is_admin()) with check (public.is_admin());

create policy "public read visible reviews" on public.reviews for select using (is_visible or public.is_admin());
create policy "customers create reviews" on public.reviews for insert with check (auth.uid() = user_id);
create policy "customers update own reviews" on public.reviews for update using (auth.uid() = user_id or public.is_admin()) with check (auth.uid() = user_id or public.is_admin());

create policy "public read settings" on public.restaurant_settings for select using (true);
create policy "admin write settings" on public.restaurant_settings for all using (public.is_admin()) with check (public.is_admin());
create policy "public read gallery" on public.gallery for select using (is_visible or public.is_admin());
create policy "admin write gallery" on public.gallery for all using (public.is_admin()) with check (public.is_admin());
create policy "public read active promos" on public.promos for select using (is_active or public.is_admin());
create policy "admin write promos" on public.promos for all using (public.is_admin()) with check (public.is_admin());
create policy "admin read notifications" on public.notifications for select using (public.is_admin());
create policy "authenticated create notification logs" on public.notifications for insert to authenticated with check (auth.uid() is not null);
create policy "admin write notifications" on public.notifications for all using (public.is_admin()) with check (public.is_admin());
create policy "own loyalty" on public.loyalty_logs for select using (auth.uid() = user_id or public.is_admin());
create policy "admin loyalty" on public.loyalty_logs for all using (public.is_admin()) with check (public.is_admin());
create policy "admin activity" on public.activity_logs for all using (public.is_admin()) with check (public.is_admin());
