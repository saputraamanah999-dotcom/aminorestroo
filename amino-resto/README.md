# Amino Resto Bali Static SPA V2

Amino Resto Bali adalah static SPA vanilla HTML/CSS/JavaScript untuk restoran natural luxury dining di **Uluwatu St No.77, Ungasan, Bali**. Tidak ada React, Next.js, Vite, Tailwind, TypeScript frontend, JSX/TSX, package.json, npm install, atau build step.

## Supabase Auth Settings

Di Supabase Dashboard → Authentication → URL Configuration:

- Site URL: `https://aminoresto.vercel.app`
- Redirect URLs:
  - `https://aminoresto.vercel.app/auth/callback`
  - `https://aminoresto.vercel.app/**`

Frontend memakai `window.location.origin`, bukan localhost. Email sign-up memakai `emailRedirectTo: ${window.location.origin}/auth/callback`, dan Google OAuth memakai `redirectTo: ${window.location.origin}/auth/callback`.

## Setup Supabase

1. Buat project Supabase.
2. Pastikan Project URL dan publishable key di `js/config.js` sesuai:
   - `https://embcudmcwrlazvuenayv.supabase.co`
   - `sb_publishable_OabYUWwhjjcbkjHSmAfRQQ_CJsLoIf1`
3. Jangan menaruh service role key, SMTP password, Gmail password, Fonnte token, atau secret lain di frontend.

## Urutan menjalankan SQL

Jalankan dari SQL Editor Supabase secara berurutan:

1. `supabase/schema.sql`
2. `supabase/rls-policies.sql`
3. `supabase/storage-policies.sql`
4. `supabase/seed-menu.sql`

Jika muncul error schema cache seperti `Could not find the table public.reviews`, jalankan:

```sql
-- Supabase SQL Editor
-- file: supabase/fix-missing-tables.sql
```

Setelah menjalankan SQL, buka Supabase Dashboard → API dan tunggu schema cache refresh, atau reload project/API jika perlu.

## Storage Bucket

`supabase/storage-policies.sql` membuat bucket:

- `menu-images`
- `gallery`
- `avatars`
- `restaurant-assets`

Policy:

- Public read untuk asset publik.
- Upload/update/delete avatar hanya authenticated user untuk folder miliknya (`avatars/<user_id>/...`).
- Upload/update/delete menu, gallery, dan restaurant assets hanya admin berdasarkan `profiles.role = 'admin'`.
- Tidak ada anonymous upload.

## Google OAuth

1. Supabase Dashboard → Authentication → Providers → Google.
2. Enable Google.
3. Isi Client ID dan Client Secret dari Google Cloud Console.
4. Tambahkan redirect URL Supabase ke Google OAuth consent.
5. Pastikan redirect URL aplikasi sesuai bagian **Supabase Auth Settings**.

## Membuat Admin

Password admin jangan ditaruh di frontend.

1. Buat user admin di Supabase Auth dengan email `aminoresto@gmail.com`.
2. Set password di Supabase Auth dashboard.
3. Jalankan SQL:

```sql
update profiles
set role = 'admin'
where id = (
  select id from auth.users
  where email = 'aminoresto@gmail.com'
);
```

4. Logout lalu login kembali. Route `#/admin` hanya bisa dibuka jika Supabase Auth aktif dan `profiles.role = 'admin'`.

## Deploy ke Vercel tanpa build step

1. Import folder `amino-resto` ke Vercel sebagai static project.
2. Framework preset: `Other` atau static.
3. Build command: kosongkan.
4. Output directory: `.`.
5. `vercel.json` memiliki rewrite fallback ke `/index.html`.

## Edge Function Email Notification

Deploy function:

```bash
supabase functions deploy send-order-email
```

Set secrets:

```bash
supabase secrets set SMTP_HOST=...
supabase secrets set SMTP_PORT=...
supabase secrets set SMTP_USER=...
supabase secrets set SMTP_PASS=...
supabase secrets set SMTP_FROM=...
supabase secrets set ADMIN_EMAIL=aminoresto@gmail.com
```

Function menangani event:

- New order
- New booking
- New review / low rating review
- Customer register
- Order status update

Jika Edge Function gagal, frontend tetap mencoba menyimpan log failed ke table `notifications`.

## Optional WhatsApp Auto Send via Fonnte

Frontend hanya membuka `https://wa.me/6282341885469?text=...`, sehingga user tetap perlu klik kirim di aplikasi WhatsApp. Untuk auto-send, buat Edge Function terpisah dan simpan token sebagai secret:

```bash
supabase secrets set FONNTE_TOKEN=...
```

Jangan pernah menaruh `FONNTE_TOKEN` di frontend.

## Cara Test Order

1. Buka `#/home`.
2. Buka `#/menu`.
3. Klik **Add to cart**.
4. Buka cart/checkout.
5. Pilih order type: Dine In, Takeaway, Delivery, atau Online.
6. Untuk delivery, isi alamat dan klik **Use my location** jika diizinkan browser.
7. Klik **WhatsApp Order**, **Copy Order Text**, atau **Save Order & WhatsApp**.
8. Klik **Place order** untuk menyimpan ke Supabase.
9. Buka `#/orders` untuk realtime tracking dan **Print receipt**.
10. Admin membuka `#/admin` untuk melihat dashboard realtime.

## Upload Foto Menu dari Admin

1. Login sebagai admin.
2. Buka `#/admin` → **Menu Manager**.
3. Pilih file pada **Upload image to Supabase Storage** untuk preview.
4. Upload ke bucket `menu-images` melalui admin flow atau Supabase Dashboard.
5. Simpan public URL ke `image_url` atau isi manual di **Input image URL manual**.
6. Jika foto belum ada, biarkan `image_url` `null`; frontend memakai placeholder SVG.

## Harga dan Pajak

- Semua harga disimpan sebagai integer Rupiah, contoh `70 K` menjadi `70000`.
- Banyak harga/ukuran disimpan di `item_variants`.
- Aplikasi memakai `Intl.NumberFormat('id-ID')` untuk Rupiah.
- Teks **PRICES ARE NOT FIXED**, **Tax 10%**, dan **Service 5%** muncul di menu, checkout, receipt, dan footer.

## QA Checklist

- Tidak ada `.tsx`.
- Tidak ada `.jsx`.
- Tidak ada React import.
- Tidak ada Next.js.
- Tidak ada package.json.
- Tidak ada binary image/audio baru.
- `index.html`, `css/`, `js/`, `supabase/`, `vercel.json`, dan README tersedia.
