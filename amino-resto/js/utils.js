(function(A){
  const defaultAddress = 'Uluwatu St No.77, Ungasan, Bali';
  A.$ = (sel, root=document) => root.querySelector(sel);
  A.$$ = (sel, root=document) => Array.from(root.querySelectorAll(sel));
  A.escape = value => String(value ?? '').replace(/[&<>'"]/g, char => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[char]));
  A.formatRupiah = value => new Intl.NumberFormat('id-ID',{style:'currency',currency:'IDR',maximumFractionDigits:0}).format(Number(value || 0));
  A.totals = subtotal => {
    const taxRate = Number(A.settings?.data?.tax_rate ?? A.config.taxRate ?? .10);
    const serviceRate = Number(A.settings?.data?.service_rate ?? A.config.serviceRate ?? .05);
    const tax = Math.round(Number(subtotal || 0) * taxRate);
    const service = Math.round(Number(subtotal || 0) * serviceRate);
    return { subtotal:Number(subtotal || 0), tax, service, total:Number(subtotal || 0)+tax+service, taxRate, serviceRate };
  };
  A.placeholder = type => type === 'gallery' ? 'assets/placeholder-gallery.svg' : 'assets/placeholder-menu.svg';
  A.empty = text => `<div class="empty"><div class="empty-icon">✦</div><h3>Belum ada data</h3><p>${A.escape(text)}</p></div>`;
  A.skeleton = (count=3) => `<div class="grid menu-grid">${Array.from({length:count},()=>'<div class="card skeleton-card"><span></span><b></b><p></p><p></p></div>').join('')}</div>`;
  A.toast = (message, type='info') => {
    const wrap = A.$('#toastWrap') || document.body.appendChild(Object.assign(document.createElement('div'),{id:'toastWrap',className:'toast-wrap'}));
    const el = document.createElement('div');
    el.className = `toast toast-${type}`;
    el.textContent = message;
    wrap.appendChild(el);
    setTimeout(()=>el.classList.add('leaving'), 3400);
    setTimeout(()=>el.remove(), 3900);
  };
  A.beep = () => {
    try {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if(!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine'; osc.frequency.value = 740;
      gain.gain.setValueAtTime(.0001, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(.08, ctx.currentTime + .02);
      gain.gain.exponentialRampToValueAtTime(.0001, ctx.currentTime + .22);
      osc.connect(gain); gain.connect(ctx.destination); osc.start(); osc.stop(ctx.currentTime + .24);
    } catch {}
  };
  A.browserNotify = (title, body) => {
    if('Notification' in window && Notification.permission === 'granted') { new Notification(title,{body,icon:'assets/logo.svg'}); A.beep(); return; }
    A.toast(`${title}: ${body}`); A.beep();
  };
  A.askNotificationBanner = () => {
    if(!('Notification' in window) || localStorage.getItem('amino_notification_prompt')) return;
    const banner = document.createElement('div');
    banner.className = 'notification-banner';
    banner.innerHTML = '<strong>Izinkan notifikasi untuk update order dan promo?</strong><div><button id="allowNotify" class="btn btn-primary">Izinkan</button><button id="laterNotify" class="btn btn-ghost">Nanti</button></div>';
    document.body.appendChild(banner);
    A.$('#allowNotify',banner).addEventListener('click',async()=>{ localStorage.setItem('amino_notification_prompt','yes'); await Notification.requestPermission(); banner.remove(); });
    A.$('#laterNotify',banner).addEventListener('click',()=>{ localStorage.setItem('amino_notification_prompt','later'); banner.remove(); });
  };
  A.openModal = html => {
    const root=A.$('#modalRoot');
    root.innerHTML = `<div class="modal-backdrop"><div class="modal animate-pop">${html}</div></div>`;
    root.querySelector('.modal-backdrop').addEventListener('click', e=>{ if(e.target.classList.contains('modal-backdrop')) A.closeModal(); });
  };
  A.closeModal = () => { const root=A.$('#modalRoot'); if(root) root.innerHTML=''; };
  A.ripple = event => {
    const btn = event.currentTarget;
    const circle = document.createElement('span');
    const size = Math.max(btn.clientWidth, btn.clientHeight);
    circle.className = 'ripple'; circle.style.width = circle.style.height = `${size}px`;
    circle.style.left = `${event.offsetX - size/2}px`; circle.style.top = `${event.offsetY - size/2}px`;
    btn.appendChild(circle); setTimeout(()=>circle.remove(), 650);
  };
  A.bindRipples = (root=document) => A.$$('.btn,.icon-button,.bottom-nav a', root).forEach(btn => { btn.removeEventListener('click', A.ripple); btn.addEventListener('click', A.ripple); });
  A.copyText = async text => { await navigator.clipboard.writeText(text); A.toast('Order text berhasil disalin.'); };
  A.getSetting = (key, fallback='') => A.settings?.data?.[key] || fallback;
  A.address = () => A.getSetting('address', defaultAddress);
  A.openMaps = (lat,lng) => window.open(lat && lng ? `https://maps.google.com/?q=${lat},${lng}` : (A.getSetting('maps_url') || `https://maps.google.com/?q=${encodeURIComponent(A.address())}`),'_blank','noopener');
  A.openWhatsApp = (message='Halo Amino Resto Bali') => window.open(`https://wa.me/${A.config.whatsapp}?text=${encodeURIComponent(message)}`,'_blank','noopener');
  A.openDelivery = provider => {
    const key = provider === 'gojek' ? 'gojek_url' : 'grabfood_url';
    const search = provider === 'gojek' ? 'Amino Resto Bali Gojek' : 'Amino Resto Bali GrabFood';
    window.open(A.getSetting(key) || `https://www.google.com/search?q=${encodeURIComponent(search)}`,'_blank','noopener');
  };
  A.notifyFunction = async (payload) => {
    if(!A.supabase) return;
    const { error } = await A.supabase.functions.invoke('send-order-email',{ body:payload });
    if(error) await A.supabase.from('notifications').insert({type:payload.type||'notification',status:'failed',recipient:'admin',subject:'Edge function failed',error:error.message,payload});
  };
  A.bindStaticActions = () => {
    A.$('#footerWhatsapp')?.addEventListener('click',()=>A.openWhatsApp());
    A.$('#footerLocation')?.addEventListener('click',()=>A.openMaps());
    A.$('#footerGojek')?.addEventListener('click',()=>A.openDelivery('gojek'));
    A.$('#footerGrab')?.addEventListener('click',()=>A.openDelivery('grab'));
    A.$('#copyAddressFooter')?.addEventListener('click',()=>A.copyText(A.address()));
  };
})(window.Amino = window.Amino || {});
