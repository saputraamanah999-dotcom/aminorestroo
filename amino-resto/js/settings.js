(function(A){
  A.settings={data:null, async load(){ const {data}=await A.supabase.from('restaurant_settings').select('*').limit(1).maybeSingle(); this.data=data; if(data?.announcement) A.$('#announcement').textContent=data.announcement; if(data?.whatsapp) A.config.whatsapp=data.whatsapp; if(data?.maps_url) A.config.mapsUrl=data.maps_url; }, rating(){ return this.data?.rating_average||4.9; }, openBadge(){ return this.data?.opening_hours||'Open daily 10:00 - 22:00'; } };
})(window.Amino = window.Amino || {});
