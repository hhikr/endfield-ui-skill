// fx.js: the small motions the stylesheet cannot do alone.
// Everything here does nothing (or jumps straight to the end) under
// prefers-reduced-motion.
//
//   Readouts that settle: figures (and Latin letters) spin and lock in from
//   the left, like a counter on a panel. Anything else stays put.
//     <b data-fx-load>1,284</b>            settles once when the page opens
//     <a data-fx-host> … <b data-fx>16</b>  settles every data-fx inside when pointed at / focused
//     <a data-fx-host="k"> … <b data-fx-of="k">  the same, for matching data-fx-of anywhere
//   Theme switch, pointer parallax, sheets and dialogs, toasts, removing a row,
//   and "done" on a button: see each function below.
//
//   import { wireReadouts, wireTheme } from './fx.js'; wireReadouts(); wireTheme();

const still = matchMedia('(prefers-reduced-motion: reduce)');
const running = new WeakMap();
const MECH = 'cubic-bezier(0.7, 0, 0.2, 1)';
const SNAP = 'cubic-bezier(0.16, 1, 0.3, 1)';

const stand = (ch) => {
  if (/\d/.test(ch)) return String(Math.floor(Math.random() * 10));
  if (/[A-Za-z]/.test(ch)) return String.fromCharCode((ch < 'a' ? 65 : 97) + Math.floor(Math.random() * 26));
  return ch;
};

// Only text nodes change, so a unit in a child element (<small>小时</small>)
// survives, and an aria-label holds the real value while it spins.
const textNodes = (el) => {
  const out = [];
  const walk = document.createTreeWalker(el, NodeFilter.SHOW_TEXT);
  while (walk.nextNode()) out.push(walk.currentNode);
  return out;
};

export function scramble(el, ms = 360) {
  if (still.matches) return;
  const before = running.get(el);
  if (before) cancelAnimationFrame(before.frame);
  const nodes = before?.nodes ?? textNodes(el).map((n) => ({ n, final: n.data }));
  const final = nodes.map((x) => x.final).join('');
  if (!/[0-9A-Za-z]/.test(final)) return;
  const labelled = before ? before.labelled : el.hasAttribute('aria-label');
  if (!labelled) el.setAttribute('aria-label', final.trim());
  const started = performance.now();
  const state = { nodes, labelled, frame: 0 };
  running.set(el, state);
  const step = (now) => {
    const done = Math.min(1, (now - started) / ms);
    let locked = Math.floor(done * final.length);
    for (const x of nodes) {
      const keep = Math.max(0, Math.min(x.final.length, locked));
      x.n.data = x.final.slice(0, keep) + [...x.final.slice(keep)].map(stand).join('');
      locked -= x.final.length;
    }
    if (done < 1) state.frame = requestAnimationFrame(step);
    else {
      for (const x of nodes) x.n.data = x.final;
      if (!labelled) el.removeAttribute('aria-label');
      running.delete(el);
    }
  };
  state.frame = requestAnimationFrame(step);
}

// On open, readouts settle one after another; the whole run stays under a
// second however many there are (stagger shrinks to fit 180ms).
export function wireReadouts(root = document) {
  const load = [...root.querySelectorAll('[data-fx-load]')];
  const gap = load.length > 1 ? Math.min(40, 180 / (load.length - 1)) : 0;
  load.forEach((el, i) => setTimeout(() => scramble(el, 600), 120 + i * gap));
  root.querySelectorAll('[data-fx-host]').forEach((host) => {
    const key = host.dataset.fxHost;
    const run = () => (key ? root.querySelectorAll(`[data-fx-of="${key}"]`) : host.querySelectorAll('[data-fx]')).forEach((el) => scramble(el));
    host.addEventListener('pointerenter', run);
    host.addEventListener('focus', run);
  });
}

// A button with data-theme-toggle flips <html data-theme> between light and
// dark, remembers the choice (localStorage "theme") and keeps aria-pressed in
// step (pressed = dark). With no choice saved, <html> keeps no data-theme and
// the page follows the system.
// Where the browser has View Transitions, the new theme is uncovered in a
// circle growing from the button at about 3000px a second; pass
// { reveal: false } to switch straight away.
// To avoid a flash of the wrong theme, also set data-theme from storage in a
// tiny script in <head> before the stylesheet paints.
export function wireTheme(root = document, { reveal = true } = {}) {
  const html = document.documentElement;
  const system = matchMedia('(prefers-color-scheme: dark)');
  try {
    const saved = localStorage.getItem('theme');
    if (saved === 'light' || saved === 'dark') html.dataset.theme = saved;
  } catch {}
  const isDark = () => (html.dataset.theme ? html.dataset.theme === 'dark' : system.matches);
  const buttons = [...root.querySelectorAll('[data-theme-toggle]')];
  const sync = () => buttons.forEach((b) => b.setAttribute('aria-pressed', String(isDark())));
  const flip = () => {
    html.dataset.theme = isDark() ? 'light' : 'dark';
    try {
      localStorage.setItem('theme', html.dataset.theme);
    } catch {}
    sync();
  };
  buttons.forEach((b) =>
    b.addEventListener('click', (e) => {
      if (!reveal || still.matches || !document.startViewTransition) return flip();
      const box = b.getBoundingClientRect();
      const x = e.clientX || box.left + box.width / 2;
      const y = e.clientY || box.top + box.height / 2;
      const r = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y));
      html.classList.add('ef-theming');
      const t = document.startViewTransition(flip);
      t.ready.then(() =>
        html.animate(
          { clipPath: [`circle(0 at ${x}px ${y}px)`, `circle(${r}px at ${x}px ${y}px)`] },
          { duration: Math.max(240, Math.min(600, r / 3)), easing: MECH, pseudoElement: '::view-transition-new(root)' },
        ),
      );
      t.finished.finally(() => html.classList.remove('ef-theming'));
    }),
  );
  system.addEventListener('change', sync);
  sync();
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

// Waits for the CSS animation an element just started, or not at all when
// motion is off or nothing runs.
const settled = (el) =>
  new Promise((done) => {
    if (still.matches || !el.getAnimations({ subtree: true }).length) return done();
    Promise.allSettled(el.getAnimations({ subtree: true }).map((a) => a.finished)).then(() => done());
  });

// Sheets and dialogs on <dialog class="ef-drawer"> / <dialog class="ef-dialog">.
//   <button data-open="actions">…</button>   opens the dialog with that id
//   <button data-close>取消</button>          inside a dialog: closes it
// Opening pushes the sheet up (360ms mech) or switches the dialog on;
// closing runs the exit first, then really closes. Esc and a tap on the
// backdrop close too.
export async function closeDialog(dialog, value) {
  if (!dialog.open || dialog.classList.contains('is-closing')) return;
  dialog.classList.add('is-closing');
  await settled(dialog);
  dialog.classList.remove('is-closing');
  dialog.close(value);
}

export function wireDialogs(root = document) {
  root.querySelectorAll('[data-open]').forEach((b) =>
    b.addEventListener('click', () => document.getElementById(b.dataset.open)?.showModal()),
  );
  root.querySelectorAll('dialog:is(.ef-drawer, .ef-dialog)').forEach((d) => {
    d.addEventListener('cancel', (e) => {
      e.preventDefault();
      closeDialog(d);
    });
    d.addEventListener('click', (e) => {
      if (e.target === d) closeDialog(d); // the backdrop
      const c = e.target.closest('[data-close]');
      if (c) closeDialog(d, c.value || c.dataset.close || '');
    });
  });
}

// A toast: one line on a dark bar, held for `ms`, then wiped away.
export function toast(text, ms = 2000) {
  const el = document.createElement('div');
  el.className = 'ef-toast';
  el.setAttribute('role', 'status');
  el.textContent = text;
  (document.querySelector('.ef') ?? document.body).append(el);
  setTimeout(async () => {
    el.classList.add('is-closing');
    await settled(el);
    el.remove();
  }, ms);
  return el;
}

// Removing a row from a list: it wipes out to the right (200ms mech), then the
// rows below close the gap by sliding up (200ms snap). Only transforms move.
export async function removeRow(row) {
  if (still.matches) return row.remove();
  row.classList.add('ef-out-wipe');
  await settled(row);
  const after = [];
  for (let n = row.nextElementSibling; n; n = n.nextElementSibling) after.push([n, n.getBoundingClientRect().top]);
  row.remove();
  for (const [n, top] of after) {
    const dy = top - n.getBoundingClientRect().top;
    if (dy) n.animate([{ transform: `translateY(${dy}px)` }, { transform: 'none' }], { duration: 200, easing: SNAP });
  }
}

// "Done" on a button after it worked: yellow passes once through it, and the
// label can change for a moment ("保存" → "已保存").
export function flashDone(btn, label, ms = 1200) {
  btn.removeAttribute('aria-busy');
  btn.classList.remove('is-done');
  void btn.offsetWidth; // restart the animation
  btn.classList.add('is-done');
  if (label) {
    const was = btn.textContent;
    btn.textContent = label;
    setTimeout(() => (btn.textContent = was), ms);
  }
  setTimeout(() => btn.classList.remove('is-done'), 600);
}
