(function(A){
  const key='amino_cart_v1';
  A.storage = {
    getCart(){ try{return JSON.parse(localStorage.getItem(key))||[]}catch{return[]} },
    saveCart(cart){ localStorage.setItem(key, JSON.stringify(cart)); window.dispatchEvent(new CustomEvent('cart:changed')); },
    clearCart(){ localStorage.removeItem(key); window.dispatchEvent(new CustomEvent('cart:changed')); }
  };
})(window.Amino = window.Amino || {});
