// variant.js: picks a variant before the page paints. Load it in <head> as a
// plain (not module) script, before the stylesheet:
//   <script src="../assets/variant.js"></script>
// It sets data-ef-* on <html> from, in order of strength:
//   the address: ?variant=coldstore or single axes (?accent=ice&cut=tight …)
//   attributes already written on <html> (data-ef-variant="site", data-ef-accent=…)
// The axes and presets are explained in references/variation.md and match
// the "variant" block in tokens.json.
(() => {
  const presets = {
    standard: {},
    coldstore: { accent: 'ice', paper: 'cool', cut: 'tight', ground: 'grid', motion: 'calm' },
    site: { accent: 'amber', paper: 'warm', cut: 'wide', ground: 'hatch' },
    nightshift: { accent: 'lime', ground: 'plain', density: 'compact', motion: 'calm', theme: 'dark' },
  };
  const axes = ['accent', 'paper', 'cut', 'ground', 'density', 'motion'];
  const html = document.documentElement;
  let q;
  try {
    q = new URLSearchParams(location.search);
  } catch {
    q = new URLSearchParams();
  }
  const name = q.get('variant') || html.dataset.efVariant;
  const preset = presets[name] || {};
  if (name in presets) html.dataset.efVariant = name;
  for (const a of axes) {
    const v = q.get(a) || html.getAttribute(`data-ef-${a}`) || preset[a];
    if (v) html.setAttribute(`data-ef-${a}`, v);
  }
  // A preset may prefer a theme; a saved or explicit choice still wins.
  if (preset.theme && !html.dataset.theme && !q.get('theme')) {
    let saved = null;
    try {
      saved = localStorage.getItem('theme');
    } catch {}
    if (!saved) html.dataset.theme = preset.theme;
  }
})();
