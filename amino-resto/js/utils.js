(function(A){
  const fallbackImg = 'assets/placeholder-menu.svg';
  A.formatRupiah = n => new Intl.NumberFormat('id-ID',{style:'currency',currency:'IDR',maximumFractionDigits:0}).format(Number(n||0));
  A.escape = s => String(s ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
  A.$ = (sel, root=document) => root.querySelector(sel);
  A.$$ = (sel, root=document) => Array.from(root.querySelectorAll(sel));
  A.toast = msg => { const el=document.createElement('div'); el.className='toast'; el.textContent=msg; document.body.appendChild(el); setTimeout(()=>el.remove(),3200); };
  A.placeholder = (type='menu') => type === 'gallery' ? 'assets/placeholder-gallery.svg' : fallbackImg;
  A.totals = subtotal => ({ subtotal, tax: Math.round(subtotal*A.config.taxRate), service: Math.round(subtotal*A.config.serviceRate), total: Math.round(subtotal*(1+A.config.taxRate+A.config.serviceRate)) });
  A.openModal = html => { const root=A.$('#modalRoot'); root.innerHTML = `<div class="modal-backdrop"><div class="modal">${html}</div></div>`; root.querySelector('.modal-backdrop').addEventListener('click', e=>{ if(e.target.className==='modal-backdrop') A.closeModal(); }); };
  A.closeModal = () => { const root=A.$('#modalRoot'); if(root) root.innerHTML=''; };
  A.empty = text => `<div class="empty"><h3>Belum ada data</h3><p>${A.escape(text)}</p></div>`;
  A.openWhatsApp = (message='Halo Amino Resto') => window.open(`https://wa.me/${A.config.whatsapp}?text=${encodeURIComponent(message)}`,'_blank','noopener');
  A.getLocation = () => window.open(A.config.mapsUrl, '_blank', 'noopener');
  A.bindStaticActions = () => { A.$('#footerWhatsapp')?.addEventListener('click',()=>A.openWhatsApp()); A.$('#footerLocation')?.addEventListener('click',A.getLocation); };
})(window.Amino = window.Amino || {});
