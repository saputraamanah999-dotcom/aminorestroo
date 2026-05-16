import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import nodemailer from 'npm:nodemailer@6.9.13';

type Payload = { type: 'order' | 'booking'; id: string };

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
  if (!body.id || !['order', 'booking'].includes(body.type)) return json({ error: 'Invalid payload' }, 400);

  const table = body.type === 'order' ? 'orders' : 'bookings';
  const select = body.type === 'order' ? '*, order_items(*), profiles(email, full_name)' : '*, profiles(email, full_name)';
  const { data, error } = await supabase.from(table).select(select).eq('id', body.id).maybeSingle();
  if (error || !data) return json({ error: error?.message || 'Not found' }, 404);

  const profile = Array.isArray(data.profiles) ? data.profiles[0] : data.profiles;
  const customerEmail = profile?.email || userData.user.email;
  const subject = body.type === 'order' ? `Amino Resto Order ${body.id}` : `Amino Resto Booking ${body.id}`;
  const text = buildMessage(body.type, data, profile);
  const transporter = nodemailer.createTransport({
    host: Deno.env.get('SMTP_HOST'),
    port: Number(Deno.env.get('SMTP_PORT') || 587),
    secure: Number(Deno.env.get('SMTP_PORT') || 587) === 465,
    auth: { user: Deno.env.get('SMTP_USER'), pass: Deno.env.get('SMTP_PASS') }
  });

  const recipients = ['aminoresto@gmail.com', customerEmail].filter(Boolean);
  const logs = [];
  for (const to of recipients) {
    try {
      await transporter.sendMail({ from: Deno.env.get('SMTP_FROM'), to, subject, text });
      logs.push({ type: body.type, recipient: to, subject, status: 'sent', payload: { id: body.id } });
    } catch (err) {
      logs.push({ type: body.type, recipient: to, subject, status: 'failed', payload: { id: body.id }, error: String(err) });
    }
  }
  await supabase.from('notifications').insert(logs);
  return json({ ok: true, logs }, 200);
});

function buildMessage(type: string, data: any, profile: any) {
  const name = profile?.full_name || profile?.email || 'Customer';
  if (type === 'booking') return `Amino Resto booking from ${name}\nDate: ${data.booking_date}\nTime: ${data.booking_time}\nGuests: ${data.party_size}\nStatus: ${data.status}`;
  const items = (data.order_items || []).map((i: any) => `- ${i.quantity}x ${i.item_name}: Rp${i.total_price}`).join('\n');
  return `Amino Resto order from ${name}\nStatus: ${data.status}\nPRICES ARE NOT FIXED\nTax 10%: Rp${data.tax}\nService 5%: Rp${data.service_fee}\nTotal: Rp${data.total}\n${items}`;
}

function json(payload: unknown, status: number) { return new Response(JSON.stringify(payload), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }); }
