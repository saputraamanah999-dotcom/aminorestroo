import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import nodemailer from 'npm:nodemailer@6.9.13';

type Payload = { type: 'order' | 'booking' | 'review' | 'customer_register' | 'status_update'; id?: string; event?: string; customer_email?: string; customer_name?: string };
const corsHeaders = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type' };

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  const authHeader = req.headers.get('Authorization') || '';
  const supabase = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: 'Unauthorized' }, 401);

  const body = await req.json() as Payload;
  const adminEmail = Deno.env.get('ADMIN_EMAIL') || 'aminoresto@gmail.com';
  const appUrl = Deno.env.get('APP_URL') || 'https://aminoresto.vercel.app';
  const detail = await loadDetail(supabase, body);
  const subject = buildSubject(body, detail);
  const html = buildHtml(body, detail, appUrl);
  const customerEmail = detail?.profiles?.email || detail?.email || body.customer_email || userData.user.email;
  const recipients = [adminEmail, customerEmail].filter(Boolean);
  const transporter = nodemailer.createTransport({ host: Deno.env.get('SMTP_HOST'), port: Number(Deno.env.get('SMTP_PORT') || 587), secure: Number(Deno.env.get('SMTP_PORT') || 587) === 465, auth: { user: Deno.env.get('SMTP_USER'), pass: Deno.env.get('SMTP_PASS') } });

  const logs = [];
  for (const to of recipients) {
    try {
      await transporter.sendMail({ from: Deno.env.get('SMTP_FROM'), to, subject, html });
      logs.push({ type: body.type, recipient: to, subject, status: 'sent', payload: { ...body, detail } });
    } catch (err) {
      logs.push({ type: body.type, recipient: to, subject, status: 'failed', payload: body, error: String(err) });
    }
  }
  await supabase.from('notifications').insert(logs);
  return json({ ok: true, logs }, 200);
});

async function loadDetail(supabase: any, body: Payload) {
  if (body.type === 'order' || body.type === 'status_update') return (await supabase.from('orders').select('*, order_items(*), profiles(email, full_name, phone)').eq('id', body.id).maybeSingle()).data;
  if (body.type === 'booking') return (await supabase.from('bookings').select('*, profiles(email, full_name, phone)').eq('id', body.id).maybeSingle()).data;
  if (body.type === 'review') return (await supabase.from('reviews').select('*, profiles(email, full_name)').eq('id', body.id).maybeSingle()).data;
  return { email: body.customer_email, full_name: body.customer_name };
}
function buildSubject(body: Payload, detail: any) {
  if (body.type === 'order') return `New Order #AMN${String(body.id || '').slice(0, 6).toUpperCase()}`;
  if (body.type === 'booking') return `New Booking - Amino Resto Bali`;
  if (body.type === 'review') return Number(detail?.rating || 0) <= 3 ? `Low Rating Review ${detail?.rating} Star` : `New Review ${detail?.rating || ''} Star`;
  if (body.type === 'status_update') return `Order Status Update #AMN${String(body.id || '').slice(0, 6).toUpperCase()}`;
  return 'New Customer Register - Amino Resto Bali';
}
function buildHtml(body: Payload, detail: any, appUrl: string) {
  const brand = 'font-family:Inter,Arial,sans-serif;color:#16231f;line-height:1.55';
  const items = (detail?.order_items || []).map((i: any) => `<li>${i.quantity}x ${i.item_name} ${i.variant_name || ''} — Rp${i.total_price}</li>`).join('');
  return `<div style="${brand};background:#fbf6ec;padding:24px"><div style="max-width:680px;margin:auto;background:#fffaf2;border:1px solid #eadfcc;border-radius:24px;padding:24px"><h1 style="color:#0f5b55">Amino Resto Bali</h1><p><strong>${buildSubject(body, detail)}</strong></p><p>PRICES ARE NOT FIXED · Tax 10% · Service 5%</p><hr><pre style="white-space:pre-wrap;font-family:Inter,Arial,sans-serif">${escapeHtml(JSON.stringify(detail || body, null, 2))}</pre>${items ? `<h3>Items</h3><ul>${items}</ul>` : ''}<p><a style="background:#0f5b55;color:white;padding:12px 18px;border-radius:999px;text-decoration:none" href="${appUrl}/#/admin">Open Admin Panel</a></p></div></div>`;
}
function escapeHtml(value: string) { return value.replace(/[&<>'"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[c] || c)); }
function json(payload: unknown, status: number) { return new Response(JSON.stringify(payload), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }); }
