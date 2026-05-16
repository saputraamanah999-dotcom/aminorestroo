(function(){
  const SUPABASE_URL = 'https://embcudmcwrlazvuenayv.supabase.co';
  const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_OabYUWwhjjcbkjHSmAfRQQ_CJsLoIf1';
  const client = window.supabase ? window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY) : null;
  window.Amino = window.Amino || {};
  window.Amino.config = { SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, taxRate: .10, serviceRate: .05, whatsapp: '6281234567890', mapsUrl: 'https://maps.google.com/?q=Amino%20Resto' };
  window.Amino.supabase = client;
})();
