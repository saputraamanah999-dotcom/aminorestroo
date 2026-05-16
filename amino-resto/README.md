# Amino Resto Static SPA

Amino Resto adalah frontend static vanilla HTML/CSS/JavaScript dengan Supabase Auth, Database, Realtime, Storage, dan Edge Function. Tidak ada React, Vite, JSX, TSX, TypeScript frontend, atau build step.

## 1. Setup Supabase

1. Buat project Supabase.
2. Pastikan Project URL dan publishable key di `js/config.js` sesuai:
   - `https://embcudmcwrlazvuenayv.supabase.co`
   - `sb_publishable_OabYUWwhjjcbkjHSmAfRQQ_CJsLoIf1`
3. Jangan pernah menaruh service role key, SMTP password, Gmail password, token Telegram, atau secret lain di frontend.

## 2. Urutan menjalankan SQL

Jalankan dari SQL Editor Supabase secara berurutan:

1. `supabase/schema.sql`
2. `supabase/rls-policies.sql`
3. `supabase/storage-policies.sql`
4. `supabase/seed-menu.sql`

Schema membuat table `profiles`, `categories`, `menu_items`, `item_variants`, `orders`, `order_items`, `bookings`, `reviews`, `restaurant_settings`, `gallery`, `promos`, `notifications`, `loyalty_logs`, dan `activity_logs` dengan UUID primary key, `created_at`, `updated_at`, trigger `updated_at`, auto-create profile, dan helper `is_admin()`.

## 3. Cara membuat bucket Storage

`supabase/storage-policies.sql` membuat bucket berikut:

- `menu-images`
- `gallery`
- `avatars`
- `restaurant-assets`

Policy yang disiapkan:

- Public read untuk asset publik.
- Upload/update/delete avatar hanya user authenticated untuk folder miliknya sendiri (`avatars/<user_id>/...`).
- Upload/update/delete menu, gallery, dan restaurant assets hanya admin berdasarkan `profiles.role = 'admin'`.
- Tidak ada anonymous upload policy.

## 4. Enable Google OAuth

1. Buka Supabase Dashboard → Authentication → Providers.
2. Enable Google.
3. Isi Client ID dan Client Secret dari Google Cloud Console.
4. Tambahkan redirect URL Supabase ke Google Cloud OAuth consent.
5. Tambahkan domain Vercel di Authentication → URL Configuration setelah deploy.

## 5. Membuat akun admin

1. Register/login dengan email `aminoresto@gmail.com` melalui aplikasi.
2. Jalankan SQL berikut di Supabase SQL Editor:

```sql
UPDATE profiles SET role = 'admin' WHERE id = (SELECT id FROM auth.users WHERE email = 'aminoresto@gmail.com');
```

3. Logout lalu login kembali. Tombol Admin akan muncul jika `profiles.role = 'admin'`.

## 6. Deploy ke Vercel tanpa build step

1. Import folder `amino-resto` ke Vercel sebagai static project.
2. Framework preset: `Other` atau static.
3. Build command: kosongkan.
4. Output directory: `.`.
5. `vercel.json` sudah memiliki rewrite fallback ke `/index.html` agar SPA hash route tetap aman.

## 7. Deploy Edge Function dan secrets

Deploy function:

```bash
supabase functions deploy send-order-email
```

Set secrets SMTP:

```bash
supabase secrets set SMTP_HOST="smtp.example.com"
supabase secrets set SMTP_PORT="587"
supabase secrets set SMTP_USER="your-smtp-user"
supabase secrets set SMTP_PASS="your-smtp-password"
supabase secrets set SMTP_FROM="Amino Resto <no-reply@example.com>"
```

Function memvalidasi JWT user dari request, mengambil detail order/booking, mengirim email admin ke `aminoresto@gmail.com`, mengirim confirmation email ke customer jika email tersedia, lalu menyimpan log ke `notifications`.

## 8. Cara test order

1. Buka aplikasi.
2. Register/login sebagai customer.
3. Buka `#/menu`.
4. Klik **Add to cart** pada beberapa menu.
5. Klik **Cart** lalu **Checkout**.
6. Pastikan ringkasan menampilkan **PRICES ARE NOT FIXED**, tax 10%, service 5%, dan format Rupiah.
7. Klik **Place order**.
8. Buka `#/orders` untuk melihat tracking realtime dan tombol **Print receipt**.
9. Cek table `orders`, `order_items`, dan `notifications` di Supabase.

## 9. Cara upload foto menu dari admin

1. Login sebagai admin.
2. Buka `#/admin` → **Menu Manager**.
3. Gunakan input **Upload image** untuk memilih file.
4. Upload file ke bucket `menu-images` dari panel admin atau Supabase Dashboard.
5. Simpan public URL ke kolom `menu_items.image_url`.
6. Jika foto belum ada, biarkan `image_url` `null`; frontend otomatis menampilkan `assets/placeholder-menu.svg`.

## 10. Catatan harga dan pajak

- Semua harga disimpan sebagai integer Rupiah, contoh `70 K` menjadi `70000`.
- Banyak harga/ukuran disimpan di `item_variants`.
- Aplikasi menampilkan format Rupiah melalui `Intl.NumberFormat('id-ID')`.
- Teks **PRICES ARE NOT FIXED**, **tax 10%**, dan **service 5%** muncul di menu, checkout, receipt, dan footer.
