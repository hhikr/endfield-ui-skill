// fx.js: readouts that settle. Figures (and Latin letters) spin and lock in
// from the left, like a counter on a panel. Anything else stays put.
// Does nothing under prefers-reduced-motion.
//
//   <b data-fx-load>1,284</b>            settles once when the page opens
//   <a data-fx-host> … <b data-fx>16</b>  settles every data-fx inside when pointed at / focused
//   <a data-fx-host="k"> … <b data-fx-of="k">  the same, for matching data-fx-of anywhere
//
//   import { wireReadouts } from './fx.js'; wireReadouts();

const still = matchMedia('(prefers-reduced-motion: reduce)');
const running = new WeakMap();

const stand = (ch) => {
  if (/\d/.test(ch)) return String(Math.floor(Math.random() * 10));
  if (/[A-Za-z]/.test(ch)) return String.fromCharCode((ch < 'a' ? 65 : 97) + Math.floor(Math.random() * 26));
  return ch;
};

export function scramble(el, ms = 360) {
  if (still.matches) return;
  const before = running.get(el);
  if (before) cancelAnimationFrame(before.frame);
  const final = before?.final ?? el.textContent ?? '';
  if (!/[0-9A-Za-z]/.test(final)) return;
  const started = performance.now();
  const state = { final, frame: 0 };
  running.set(el, state);
  const step = (now) => {
    const done = Math.min(1, (now - started) / ms);
    const locked = Math.floor(done * final.length);
    el.textContent = final.slice(0, locked) + [...final.slice(locked)].map(stand).join('');
    if (done < 1) state.frame = requestAnimationFrame(step);
    else {
      el.textContent = final;
      running.delete(el);
    }
  };
  state.frame = requestAnimationFrame(step);
}

export function wireReadouts(root = document) {
  root.querySelectorAll('[data-fx-load]').forEach((el, i) => setTimeout(() => scramble(el, 700), 120 + i * 40));
  root.querySelectorAll('[data-fx-host]').forEach((host) => {
    const key = host.dataset.fxHost;
    const run = () => (key ? root.querySelectorAll(`[data-fx-of="${key}"]`) : host.querySelectorAll('[data-fx]')).forEach((el) => scramble(el));
    host.addEventListener('pointerenter', run);
    host.addEventListener('focus', run);
  });
}

// A button with data-theme-toggle flips <html data-theme> between light and
// dark and remembers the choice (localStorage "theme"). With no choice saved,
// <html> keeps no data-theme and the page follows the system.
// To avoid a flash of the wrong theme, also set data-theme from storage in a
// tiny script in <head> before the stylesheet paints.
export function wireTheme(root = document) {
  const html = document.documentElement;
  try {
    const saved = localStorage.getItem('theme');
    if (saved === 'light' || saved === 'dark') html.dataset.theme = saved;
  } catch {}
  root.querySelectorAll('[data-theme-toggle]').forEach((b) =>
    b.addEventListener('click', () => {
      const dark = html.dataset.theme ? html.dataset.theme === 'dark' : matchMedia('(prefers-color-scheme: dark)').matches;
      html.dataset.theme = dark ? 'light' : 'dark';
      try {
        localStorage.setItem('theme', html.dataset.theme);
      } catch {}
    }),
  );
}

// Pointer parallax: sets --mx / --my (-0.5…0.5) on the element as the pointer moves over it.
export function wireParallax(el) {
  if (!el || !matchMedia('(prefers-reduced-motion: no-preference) and (hover: hover)').matches) return;
  el.addEventListener('pointermove', (e) => {
    const box = el.getBoundingClientRect();
    el.style.setProperty('--mx', ((e.clientX - box.left) / box.width - 0.5).toFixed(3));
    el.style.setProperty('--my', ((e.clientY - box.top) / box.height - 0.5).toFixed(3));
  });
}
