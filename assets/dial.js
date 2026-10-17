// dial.js: the console's centrepiece. A ring of N blocks, each one a link to a
// section; pointing at a block brackets it, runs a beam in to the centre and
// shows its figure there. Inside the ring, optional gauge arcs (three quarters
// of a turn, like a meter) for live readings.
//
//   import { drawDial } from './dial.js';
//   drawDial(document.querySelector('svg.ef-dial'), {
//     sections: [{ zh: '概览', en: 'Overview', href: '#', big: 16, unit: '小时', here: true }, …],
//     gauges: [{ label: '处理器', share: 0.12 }, { label: '内存', share: 0.64 }],
//     idle: { label: '系统已运行', big: 16, unit: '小时', sub: '读数 11:36' },
//   });
//
// The SVG gets a 600×600 viewBox; size it with CSS. Styles are in endfield.css.

const NS = 'http://www.w3.org/2000/svg';
const node = (tag, attrs = {}, text) => {
  const el = document.createElementNS(NS, tag);
  for (const [k, v] of Object.entries(attrs)) el.setAttribute(k, String(v));
  if (text !== undefined) el.textContent = String(text);
  return el;
};

export function drawDial(svg, { sections, gauges = [], idle }) {
  const W = 300; // centre
  const [R1, R2, GAP] = [228, 288, 1.6];
  const step = 360 / sections.length;
  const at = (r, deg) => {
    const a = (deg * Math.PI) / 180;
    return [+(W + r * Math.sin(a)).toFixed(1), +(W - r * Math.cos(a)).toFixed(1)];
  };
  svg.setAttribute('viewBox', '0 0 600 600');
  svg.replaceChildren();
  svg.append(node('circle', { class: 'orbit', cx: W, cy: W, r: 296 }));

  // the centre: one readout at a time
  const tag = node('polygon', { class: 'core-tag', points: `${W - 44},${W - 32} ${W + 44},${W - 32} ${W + 44},${W - 19} ${W + 38},${W - 13} ${W - 44},${W - 13}` });
  const label = node('text', { class: 'core-label on-tag', x: W, y: W - 18, 'text-anchor': 'middle' });
  const big = node('text', { class: 'core', x: W, y: W + 30, 'text-anchor': 'middle' });
  const sub = node('text', { class: 'core-label', x: W, y: W + 54, 'text-anchor': 'middle' });
  const show = (s) => {
    label.textContent = s.label ?? s.zh;
    big.textContent = s.big;
    if (s.unit) big.append(node('tspan', { class: 'unit', dx: 5 }, s.unit));
    sub.textContent = s.sub ?? '';
  };

  // gauges: three-quarter arcs, nested
  gauges.forEach((g, i) => {
    const r = 140 - i * 20;
    const group = node('g', { class: `gauge${g.share > 0.85 ? ' is-alert' : ''}` });
    const arc = (cls, len) => node('circle', { class: cls, cx: W, cy: W, r, pathLength: 100, 'stroke-dasharray': `${len} 100`, transform: `rotate(-90 ${W} ${W})` });
    group.append(arc('track', 75), arc('arc', (75 * Math.max(0.004, Math.min(1, g.share))).toFixed(2)));
    // a nearly full reading gets a yellow flag behind its label
    if (g.share > 0.85) group.append(node('rect', { class: 'flag', x: W - 86, y: W - r - 8, width: 80, height: 16 }));
    group.append(node('text', { x: W - 10, y: W - r, 'text-anchor': 'end', 'dominant-baseline': 'central' }, `${g.label} ${Math.round(g.share * 100)}%`));
    svg.append(group);
  });

  sections.forEach((s, i) => {
    const mid = i * step;
    const [a0, a1] = [mid - step / 2 + GAP, mid + step / 2 - GAP];
    const o0 = at(R2, a0), o1 = at(R2, a1), i1 = at(R1, a1), i0 = at(R1, a0);
    const l0 = at(R2 + 8, a0), l1 = at(R2 + 8, a1);
    const [bx0, by0] = at(R1 - 3, mid);
    const [bx1, by1] = at(150, mid);
    const [tx, ty] = at((R1 + R2) / 2, mid);
    const a = node('a', { href: s.href ?? '#', class: `seg${s.here ? ' is-here' : ''}${s.alert ? ' is-alert' : ''}`, style: `--i:${i}` });
    a.setAttribute('aria-label', `${s.zh}：${s.big}${s.unit ?? ''}`);
    a.append(
      node('path', { class: 'lock', d: `M${l0}A${R2 + 8} ${R2 + 8} 0 0 1 ${l1}`, pathLength: 100 }),
      node('line', { class: 'beam', x1: bx0, y1: by0, x2: bx1, y2: by1, pathLength: 100 }),
      node('path', { class: 'plate', d: `M${o0}A${R2} ${R2} 0 0 1 ${o1}L${i1}A${R1} ${R1} 0 0 0 ${i0}Z` }),
      node('text', { class: 'zh', x: tx, y: ty - 4, 'text-anchor': 'middle' }, s.zh),
      node('text', { class: 'en', x: tx, y: ty + 13, 'text-anchor': 'middle' }, s.en ?? ''),
    );
    if (s.alert) {
      const [fx, fy] = at(R2 - 14, mid + step / 3);
      a.append(node('rect', { class: 'flag', x: fx - 7, y: fy - 7, width: 14, height: 14 }));
    }
    a.addEventListener('pointerenter', () => show(s));
    a.addEventListener('focus', () => show(s));
    a.addEventListener('pointerleave', () => show(idle ?? sections[0]));
    a.addEventListener('blur', () => show(idle ?? sections[0]));
    svg.append(a);
  });

  svg.append(tag, label, big, sub);
  show(idle ?? sections[0]);
}
