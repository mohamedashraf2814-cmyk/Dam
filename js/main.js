(function(){
  var q=document.getElementById('q'), links=[].slice.call(document.querySelectorAll('#nav a'));
  q.addEventListener('input',function(){ var v=q.value.trim().toLowerCase();
    links.forEach(function(a){ a.hidden = v && a.textContent.toLowerCase().indexOf(v)<0; }); });
  function openFor(hash){ if(!hash) return; var el=document.getElementById(hash.slice(1)); if(!el) return;
    var d=el.closest('details'); if(d) d.open=true;
    document.querySelectorAll('tr.hit').forEach(function(t){t.classList.remove('hit')});
    if(el.tagName==='TR'){ el.classList.add('hit'); el.scrollIntoView({block:'center'}); } }
  document.addEventListener('click',function(e){ var a=e.target.closest('a.ln'); if(!a) return;
    e.preventDefault(); openFor(a.getAttribute('href')); });
  var secs=[].slice.call(document.querySelectorAll('section.file'));
  if('IntersectionObserver' in window){ var io=new IntersectionObserver(function(es){ es.forEach(function(en){
      if(en.isIntersecting){ links.forEach(function(a){ a.classList.toggle('on', a.dataset.id===en.target.id); }); } }); },{rootMargin:'-20% 0px -70% 0px'});
    secs.forEach(function(s){io.observe(s)}); }
})();
