insert into storage.buckets (id, name, public) values ('menu-images','menu-images',true),('gallery','gallery',true),('avatars','avatars',true),('restaurant-assets','restaurant-assets',true) on conflict (id) do update set public = excluded.public;

create policy "public read menu images" on storage.objects for select using (bucket_id in ('menu-images','gallery','avatars','restaurant-assets'));
create policy "authenticated upload own avatar" on storage.objects for insert to authenticated with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "authenticated update own avatar" on storage.objects for update to authenticated using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "authenticated delete own avatar" on storage.objects for delete to authenticated using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "admin upload public assets" on storage.objects for insert to authenticated with check (bucket_id in ('menu-images','gallery','restaurant-assets') and public.is_admin());
create policy "admin update public assets" on storage.objects for update to authenticated using (bucket_id in ('menu-images','gallery','restaurant-assets') and public.is_admin()) with check (bucket_id in ('menu-images','gallery','restaurant-assets') and public.is_admin());
create policy "admin delete public assets" on storage.objects for delete to authenticated using (bucket_id in ('menu-images','gallery','restaurant-assets') and public.is_admin());
-- No anonymous upload policy is created.
