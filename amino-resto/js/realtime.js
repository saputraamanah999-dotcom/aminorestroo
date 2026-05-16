(function(A){
  A.realtime={channels:[], start(){ if(!A.supabase) return; this.stop(); ['orders','reviews','restaurant_settings','menu_items'].forEach(table=>{ const ch=A.supabase.channel(`public:${table}`).on('postgres_changes',{event:'*',schema:'public',table},()=>A.router?.render()).subscribe(); this.channels.push(ch); }); }, stop(){ this.channels.forEach(ch=>A.supabase.removeChannel(ch)); this.channels=[]; } };
})(window.Amino = window.Amino || {});
