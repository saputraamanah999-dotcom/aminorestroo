(function(A){
  A.settings={data:null, async load(){ const {data}=await A.supabase.from('restaurant_settings').select('*').limit(1).maybeSingle(); this.data=data||{}; if(this.data.announcement) A.$('#announcement').textContent=this.data.announcement; A.config.whatsapp=this.data.whatsapp||A.config.whatsapp; }, rating(){ return this.data?.rating_average||4.9; }, openBadge(){ return this.data?.open_status===false?'Closed now':(this.data?.opening_hours||'Open daily 08:00 - 22:00'); } };
})(window.Amino = window.Amino || {});
