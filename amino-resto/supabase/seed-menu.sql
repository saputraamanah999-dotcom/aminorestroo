insert into public.restaurant_settings (restaurant_name, address, announcement, opening_hours, breakfast_hours, lunch_dinner_hours, rating_average, whatsapp, maps_url, gojek_url, grabfood_url, tax_rate, service_rate)
values ('Amino Resto Bali','Uluwatu St No.77, Ungasan, Bali','PRICES ARE NOT FIXED. Tax 10% and service 5% apply. Book your natural luxury table today.','Open daily 08:00 - 22:00','08:00 - 11:00','12:00 - 22:00',4.9,'6282341885469','https://maps.google.com/?q=Amino%20Resto%20Bali%20Uluwatu%20St%20No.77%20Ungasan%20Bali',null,null,0.10,0.05)
on conflict do nothing;

insert into public.categories (name, slug, sort_order) values
('Breakfast','breakfast',1),('Lunch & Dinner','lunch-dinner',2),('Smoothie Bowls','smoothie-bowls',3),('Salads & Bowls','salads-bowls',4),('Soups','soups',5),('Wraps & Quesadilla','wraps-quesadilla',6),('Main Menu','main-menu',7),('Grain Bowls','grain-bowls',8),('Desserts','desserts',9),('Coffee','coffee',10),('Decaf Coffee','decaf-coffee',11),('Not Coffee','not-coffee',12),('Tea','tea',13),('Lemonades','lemonades',14),('Mixed Juices','mixed-juices',15),('Single Juices','single-juices',16),('Probiotic Drinks','probiotic-drinks',17),('Smoothies','smoothies',18),('Protein Smoothies','protein-smoothies',19),('Kombucha','kombucha',20),('Create Your Plate','create-your-plate',21),('Add-ons','add-ons',22)
on conflict (slug) do update set name=excluded.name, sort_order=excluded.sort_order;

with c as (select id, slug from public.categories)
insert into public.menu_items (category_id, name, description, price, image_url, dietary_label, is_featured, is_recommended, is_best_seller, is_new, sort_order) values
((select id from c where slug='breakfast'),'Amino Breakfast','Eggs, avocado, greens, sourdough, probiotic side.',125000,null,'Breakfast',true,true,true,false,1),
((select id from c where slug='breakfast'),'Avocado Toast','Avocado, herbs, seeds, lemon, choice of bread.',95000,null,'Vegetarian',true,true,true,false,2),
((select id from c where slug='breakfast'),'Tuna Toast','Tuna, herbs, soft egg, pickles, fresh greens.',105000,null,'Protein',true,false,false,false,3),
((select id from c where slug='breakfast'),'Top Combo Breakfast','Balanced breakfast plate with coffee or tea.',145000,null,'Combo',true,true,false,true,4),
((select id from c where slug='breakfast'),'Oat Porridge With Bacon/Salmon','Warm oats with savory topping option.',98000,null,'Warm Bowl',false,false,false,false,5),
((select id from c where slug='breakfast'),'Oat Porridge With Tuna','Warm oats with tuna, herbs, and seeds.',88000,null,'Warm Bowl',false,false,false,false,6),
((select id from c where slug='salads-bowls'),'Green Power Salad','Greens, avocado, cucumber, seeds, citrus dressing.',85000,null,'Fresh',true,true,false,false,7),
((select id from c where slug='salads-bowls'),'Quinoa Tofu Bowl','Quinoa, marinated tofu, vegetables, tahini sauce.',95000,null,'Vegan',true,true,true,false,8),
((select id from c where slug='soups'),'Forest Mushroom Soup','Creamy mushroom soup with garlic crouton.',45000,null,'Comfort',false,false,false,false,9),
((select id from c where slug='wraps-quesadilla'),'Chicken Wrap','Grilled chicken, vegetables, house sauce.',78000,null,'Wrap',false,false,false,false,10),
((select id from c where slug='wraps-quesadilla'),'Veggie Quesadilla','Cheese, vegetables, salsa, sour cream.',72000,null,'Vegetarian',false,false,false,false,11),
((select id from c where slug='main-menu'),'Herb Roasted Chicken','Ayam panggang herbs, mashed potato, natural jus.',85000,null,'Best Seller',true,true,true,false,12),
((select id from c where slug='main-menu'),'Pan Seared Barramundi','Barramundi, lemon butter, grilled vegetables.',95000,null,'Seafood',true,true,false,false,13),
((select id from c where slug='main-menu'),'Wagyu Beef Rice Bowl','Wagyu slices, garlic rice, onsen egg, tare sauce.',125000,null,'Premium',true,true,true,false,14),
((select id from c where slug='grain-bowls'),'Amino Grain Bowl','Build your signature grain bowl.',90000,null,'Custom',true,true,false,true,15),
((select id from c where slug='smoothie-bowls'),'Tropical Smoothie Bowl','Banana, mango, coconut, granola.',78000,null,'Smoothie Bowl',false,true,false,false,16),
((select id from c where slug='smoothie-bowls'),'Green Smoothie Bowl','Greens, banana, spirulina, granola.',82000,null,'Green',false,true,false,false,17),
((select id from c where slug='desserts'),'Palm Sugar Panna Cotta','Gula aren panna cotta, crumble, seasonal fruit.',40000,null,'Dessert',false,false,false,false,18),
((select id from c where slug='desserts'),'Raw Chocolate Tart','Dark chocolate, nuts, coconut cream.',52000,null,'Dessert',false,true,false,false,19),
((select id from c where slug='desserts'),'Coconut Chia Pudding','Chia, coconut milk, tropical fruit.',48000,null,'Dessert',false,false,false,false,20),
((select id from c where slug='coffee'),'Espresso','Single shot espresso.',28000,null,'Coffee',false,false,false,false,21),
((select id from c where slug='coffee'),'Amino Latte','Espresso, fresh milk, optional oat milk.',32000,null,'Coffee',false,true,false,false,22),
((select id from c where slug='coffee'),'Cappuccino','Classic cappuccino.',34000,null,'Coffee',false,false,false,false,23),
((select id from c where slug='decaf-coffee'),'Decaf Latte','Decaf espresso with milk.',36000,null,'Decaf',false,false,false,false,24),
((select id from c where slug='not-coffee'),'Matcha Latte','Premium matcha with milk.',42000,null,'Not Coffee',false,true,false,false,25),
((select id from c where slug='not-coffee'),'Cacao Latte','Warm cacao, milk, cinnamon.',40000,null,'Not Coffee',false,false,false,false,26),
((select id from c where slug='tea'),'Botanical Iced Tea','Tea dingin dengan herbs, lemon, dan madu.',30000,null,'Tea',false,false,false,false,27),
((select id from c where slug='tea'),'Ginger Lemongrass Tea','Warm herbal tea.',30000,null,'Tea',false,false,false,false,28),
((select id from c where slug='lemonades'),'Classic Lemonade','Lemon, honey, sparkling water.',32000,null,'Lemonade',false,false,false,false,29),
((select id from c where slug='mixed-juices'),'Green Detox Juice','Celery, apple, cucumber, lime.',45000,null,'Juice',false,true,false,false,30),
((select id from c where slug='single-juices'),'Orange Juice','Fresh orange juice.',38000,null,'Juice',false,false,false,false,31),
((select id from c where slug='probiotic-drinks'),'Kefir Berry','Probiotic kefir with berries.',48000,null,'Probiotic',false,true,false,false,32),
((select id from c where slug='smoothies'),'Mango Banana Smoothie','Mango, banana, coconut milk.',52000,null,'Smoothie',false,true,false,false,33),
((select id from c where slug='protein-smoothies'),'Chocolate Protein Smoothie','Protein, banana, cacao, peanut butter.',68000,null,'Protein',false,true,true,false,34),
((select id from c where slug='kombucha'),'House Kombucha','Refreshing fermented tea.',42000,null,'Kombucha',false,false,false,false,35),
((select id from c where slug='create-your-plate'),'Create Your Plate','Choose protein, grain, vegetables, sauce.',110000,null,'Custom',true,true,false,true,36),
((select id from c where slug='add-ons'),'Add-ons','Extra egg, avocado, salmon, bacon, tofu, protein.',15000,null,'Add-on',false,false,false,false,37)
on conflict do nothing;

insert into public.item_variants (menu_item_id, name, price) select id, 'multigrain bread', 95000 from public.menu_items where name='Avocado Toast' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'croissant', 110000 from public.menu_items where name='Avocado Toast' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'bacon', 98000 from public.menu_items where name='Oat Porridge With Bacon/Salmon' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'salmon', 118000 from public.menu_items where name='Oat Porridge With Bacon/Salmon' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'chicken', 98000 from public.menu_items where name='Amino Grain Bowl' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'tofu', 90000 from public.menu_items where name='Amino Grain Bowl' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'salmon', 125000 from public.menu_items where name='Amino Grain Bowl' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'Regular', 32000 from public.menu_items where name='Amino Latte' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'Oat Milk', 38000 from public.menu_items where name='Amino Latte' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'Extra egg', 15000 from public.menu_items where name='Add-ons' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'Avocado', 25000 from public.menu_items where name='Add-ons' on conflict do nothing;
insert into public.item_variants (menu_item_id, name, price) select id, 'Salmon', 45000 from public.menu_items where name='Add-ons' on conflict do nothing;

insert into public.gallery (title, category, image_url, sort_order) values ('Dining Room','Interior',null,1),('Signature Plating','Food',null,2),('Natural Ingredients','Ingredients',null,3) on conflict do nothing;
insert into public.promos (title, description, code, discount_percent, is_active) values ('Opening Table Treat','Complimentary dessert for selected bookings. PRICES ARE NOT FIXED. Tax 10%. Service 5%.','AMINOOPEN',10,true) on conflict (code) do nothing;
