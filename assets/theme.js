// Injects the light/dark toggle. The button is created here rather than written
// into every page because index.html and apps.html carry their own <head> and do
// not go through _layouts/base.html, so shared markup would have to be
// triplicated and kept in sync.
(function () {
  var root = document.documentElement;

  function current() {
    return root.getAttribute('data-theme') ||
      (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  }

  var btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'theme-toggle';
  btn.textContent = '◐';
  btn.setAttribute('aria-label', 'Toggle light or dark theme');

  function sync() { btn.setAttribute('aria-pressed', current() === 'dark' ? 'true' : 'false'); }

  btn.addEventListener('click', function () {
    var next = current() === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    try { localStorage.setItem('digitalis-theme', next); } catch (e) {}
    sync();
  });

  sync();
  document.body.appendChild(btn);
})();
