insert into public.restaurant_settings (announcement, opening_hours, rating_average, whatsapp, maps_url, gojek_url, grabfood_url)
values ('PRICES ARE NOT FIXED. Tax 10% and service 5% apply. Book your natural luxury table today.', 'Open daily 10:00 - 22:00', 4.9, '6281234567890', 'https://maps.google.com/?q=Amino%20Resto', 'https://gojek.com', 'https://food.grab.com')
on conflict do nothing;

insert into public.categories (name, slug, sort_order) values
('Signature', 'signature', 1), ('Appetizer', 'appetizer', 2), ('Soup & Salad', 'soup-salad', 3), ('Main Course', 'main-course', 4), ('Pasta & Rice', 'pasta-rice', 5), ('Dessert', 'dessert', 6), ('Coffee', 'coffee', 7), ('Tea & Mocktail', 'tea-mocktail', 8), ('Family Package', 'family-package', 9)
on conflict (slug) do update set name=excluded.name, sort_order=excluded.sort_order;

with c as (select id, slug from public.categories), inserted as (
insert into public.menu_items (category_id, name, description, price, image_url, dietary_label, is_featured, sort_order) values
((select id from c where slug='signature'),'Amino Signature Platter','Premium platter dengan herbs, grilled protein, seasonal vegetables, dan house sauce.',70000,null,'Signature',true,1),
((select id from c where slug='appetizer'),'Truffle Cassava Bites','Singkong renyah, truffle aroma, aioli daun jeruk.',35000,null,'Vegetarian',true,2),
((select id from c where slug='soup-salad'),'Forest Mushroom Soup','Sup jamur creamy dengan garlic crouton.',45000,null,'Comfort',false,3),
((select id from c where slug='soup-salad'),'Amino Garden Salad','Sayur segar, edible flowers, citrus vinaigrette.',42000,null,'Fresh',false,4),
((select id from c where slug='main-course'),'Herb Roasted Chicken','Ayam panggang herbs, mashed potato, natural jus.',85000,null,'Best Seller',true,5),
((select id from c where slug='main-course'),'Pan Seared Barramundi','Barramundi, lemon butter, grilled vegetables.',95000,null,'Seafood',true,6),
((select id from c where slug='main-course'),'Wagyu Beef Rice Bowl','Wagyu slices, garlic rice, onsen egg, tare sauce.',125000,null,'Premium',true,7),
((select id from c where slug='pasta-rice'),'Aglio Olio Prawn','Pasta bawang putih, prawn, chili flakes.',78000,null,'Spicy',false,8),
((select id from c where slug='pasta-rice'),'Nasi Goreng Amino','Nasi goreng signature dengan satay lilit dan acar.',68000,null,'Local',true,9),
((select id from c where slug='dessert'),'Palm Sugar Panna Cotta','Panna cotta gula aren, crumble, seasonal fruit.',40000,null,'Sweet',false,10),
((select id from c where slug='coffee'),'Amino Latte','Espresso, fresh milk, optional oat milk.',32000,null,'Coffee',false,11),
((select id from c where slug='tea-mocktail'),'Botanical Iced Tea','Tea dingin dengan herbs, lemon, dan madu.',30000,null,'Refreshing',false,12),
((select id from c where slug='tea-mocktail'),'Tropical Basil Mocktail','Nanas, basil, lime, soda.',38000,null,'Mocktail',true,13),
((select id from c where slug='family-package'),'Family Feast','Paket keluarga berisi platter, mains, rice, dessert, dan drinks.',250000,null,'Share',true,14)
returning id, name)
select * from inserted;

insert into public.item_variants (menu_item_id, name, price)
select id, 'Regular', 32000 from public.menu_items where name='Amino Latte'
on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price)
select id, 'Oat Milk', 38000 from public.menu_items where name='Amino Latte'
on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price)
select id, 'Regular', 250000 from public.menu_items where name='Family Feast'
on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price)
select id, 'Large', 350000 from public.menu_items where name='Family Feast'
on conflict do nothing;

insert into public.gallery (title, image_url, sort_order) values ('Dining Room', null, 1), ('Signature Plating', null, 2), ('Natural Ingredients', null, 3) on conflict do nothing;
insert into public.promos (title, description, code, discount_percent, is_active) values ('Opening Table Treat', 'Complimentary dessert for selected bookings.', 'AMINOOPEN', 10, true) on conflict (code) do nothing;
