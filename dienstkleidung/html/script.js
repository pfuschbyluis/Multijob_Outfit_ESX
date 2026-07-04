/* ============================================================
   Dienstkleidung – Custom NUI · Logik
   ============================================================ */

const app        = document.getElementById('app');
const menu       = document.getElementById('menu');
const eyebrow    = document.getElementById('eyebrow');
const title      = document.getElementById('menuTitle');
const jobIcon    = document.getElementById('jobIcon');
const rankLabel  = document.getElementById('rankLabel');
const rankPill   = document.getElementById('rank');
const countEl    = document.getElementById('count');
const outfitList = document.getElementById('outfitList');
const closeBtn   = document.getElementById('closeBtn');
const root       = document.getElementById('root');

const IN_FIVEM = window.location.hostname === 'nui-game-internal';
const resourceName = IN_FIVEM ? GetParentResourceName() : 'preview';

/* ---------- Icon-Set (Inline-SVG, erbt currentColor) ---------- */

const ICON = {
    flame:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"><path d="M12 3c.6 3.4-2.3 4.4-2.3 7.2 0 .9.4 1.6.9 2.1-1.7-.2-2.8-1.7-2.8-3.6 0-.5.1-1 .2-1.4C6.3 9 5.5 11 5.5 13.2 5.5 17 8.4 20 12 20s6.5-3 6.5-6.8c0-3.6-2.7-5.7-3.9-8C13.9 7 12.9 7.7 12 7c-.9-.7-.6-2.6 0-4Z"/></svg>',
    shield:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"><path d="M12 3l7 2.6v5.1c0 4.4-3 7.6-7 9.3-4-1.7-7-4.9-7-9.3V5.6L12 3Z"/><path d="m9.3 11.7 1.9 1.9 3.6-3.8"/></svg>',
    cross:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"><path d="M9.5 3.5h5v6h6v5h-6v6h-5v-6h-6v-5h6Z"/></svg>',
    badge:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"><path d="M12 3l7 2.6v5.1c0 4.4-3 7.6-7 9.3-4-1.7-7-4.9-7-9.3V5.6L12 3Z"/><circle cx="12" cy="10" r="2.2"/><path d="M8.7 16c.5-1.7 1.8-2.6 3.3-2.6s2.8.9 3.3 2.6"/></svg>',
    wrench:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"><path d="M15.5 7.5a3.6 3.6 0 0 1-4.7 4.4l-5 5a1.8 1.8 0 0 1-2.6-2.6l5-5A3.6 3.6 0 0 1 16.5 4l-2.5 2.5.9 2.6 2.6.9L20 7.5"/></svg>',
    bolt:    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"><path d="M13 3 5 13h5l-1 8 8-10h-5l1-8Z"/></svg>',
    headset: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"><path d="M5 13v-1a7 7 0 0 1 14 0v1"/><path d="M5 13h2v5H6a2 2 0 0 1-2-2v-1a2 2 0 0 1 1-2Zm14 0h-2v5h1a2 2 0 0 0 2-2v-1a2 2 0 0 0-1-2Z"/><path d="M19 18v.5a2.5 2.5 0 0 1-2.5 2.5H12"/></svg>',
    shirt:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round"><path d="M9 4 5 6.2 3.5 9.6 6 11v8.5h12V11l2.5-1.4L19 6.2 15 4a3 3 0 0 1-6 0Z"/></svg>',
    restore: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"><path d="M4 5v5h5"/><path d="M4.5 10a8 8 0 1 1-1 5"/></svg>',
    chevron: '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 6 6 6-6 6"/></svg>',
    success: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 6.5"/></svg>',
    error:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 7v6"/><circle cx="12" cy="16.5" r="0.4"/><path d="M12 16.5h.01"/></svg>',
    info:    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 11v6"/><path d="M12 7.5h.01"/></svg>',
    warning: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4 3 19h18L12 4Z"/><path d="M12 10v4"/><path d="M12 17h.01"/></svg>'
};

/* ---------- Job-Konfiguration: Name · Akzent · Icon ---------- */

const JOBS = {
    fire:       { name: 'Feuerwehr',      accent: '#ff5a3c', icon: ICON.flame },
    police:     { name: 'Polizei',        accent: '#3b82f6', icon: ICON.shield },
    ambulance:  { name: 'Rettungsdienst', accent: '#22b06d', icon: ICON.cross },
    bka:        { name: 'BKA',            accent: '#7c6cf6', icon: ICON.badge },
    uke:        { name: 'UKE',            accent: '#15bcc8', icon: ICON.cross },
    ils:        { name: 'Leitstelle',     accent: '#f0a23a', icon: ICON.headset },
    mechanic:   { name: 'Mechaniker',     accent: '#f2922d', icon: ICON.wrench },
    stadtwerke: { name: 'Stadtwerke',     accent: '#e6c12e', icon: ICON.bolt }
};

const FALLBACK_JOB = { name: '', accent: '#4d8df0', icon: ICON.shirt };

// Erkennt den Job anhand des Schlüssels (fire, police …) ODER eines
// beliebigen Labels (z. B. "Feuerwehr", "Staatliche Polizei", "LSPD").
const JOB_ALIASES = [
    ['fire',       ['fire', 'feuer', 'firefighter', 'lsfd']],
    ['police',     ['police', 'polizei', 'cop', 'lspd', 'bcso', 'sheriff', 'sast']],
    ['ambulance',  ['ambulance', 'rettung', 'sani', 'ems', 'medic', 'notarzt', 'lsmd']],
    ['bka',        ['bka', 'kripo', 'lka']],
    ['uke',        ['uke', 'klinik', 'krankenhaus', 'hospital', 'doctor', 'arzt']],
    ['ils',        ['ils', 'leitstelle', 'dispatch', 'disponent']],
    ['mechanic',   ['mechanic', 'mechaniker', 'kfz', 'werkstatt', 'tuner', 'bennys']],
    ['stadtwerke', ['stadtwerke', 'strom', 'energie', 'werke']]
];

function resolveJob(raw) {
    const v = String(raw || '').toLowerCase().trim();
    if (!v) return FALLBACK_JOB;
    if (JOBS[v]) return JOBS[v];                       // exakter Schlüssel
    for (const [key, words] of JOB_ALIASES) {          // Label-Treffer
        if (words.some(w => v.includes(w))) return JOBS[key];
    }
    return FALLBACK_JOB;
}

/* ---------- Helfer ---------- */

const EASE = 'cubic-bezier(0.22, 1, 0.36, 1)';
function animateIn(el, fromX, delay, dur) {
    if (!el.animate) return;
    el.animate(
        [{ transform: `translateX(${fromX}px)` }, { transform: 'none' }],
        { duration: dur || 320, delay: delay || 0, easing: EASE }
    );
}

function post(name, data = {}) {
    if (!IN_FIVEM) return Promise.resolve();
    return fetch(`https://${resourceName}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).catch((err) => console.error('[job_outfit] NUI-Post fehlgeschlagen:', name, err));
}

function hexToRgb(hex) {
    const h = hex.replace('#', '');
    const v = h.length === 3 ? h.split('').map(c => c + c).join('') : h;
    return [parseInt(v.slice(0, 2), 16), parseInt(v.slice(2, 4), 16), parseInt(v.slice(4, 6), 16)];
}

function applyAccent(hex) {
    const [r, g, b] = hexToRgb(hex);
    const s = document.documentElement.style;
    s.setProperty('--accent', hex);
    s.setProperty('--accent-weak', `rgba(${r}, ${g}, ${b}, 0.14)`);
    s.setProperty('--accent-mid',  `rgba(${r}, ${g}, ${b}, 0.24)`);
    s.setProperty('--accent-line', `rgba(${r}, ${g}, ${b}, 0.55)`);
}

function escapeHtml(value) {
    return String(value)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}

function closeMenu() {
    hideMenu();
    post('close');
}

function hideMenu() {
    app.classList.add('hidden');
}

/* ---------- Render ---------- */

function makeItem({ icon, label, sub, extraClass = '', onClick, index = 0, chevIcon }) {
    const btn = document.createElement('button');
    btn.className = 'item' + (extraClass ? ' ' + extraClass : '');
    btn.style.setProperty('--i', index);
    btn.innerHTML = `
        <span class="item__icon">${icon}</span>
        <span class="item__body">
            <span class="item__label">${escapeHtml(label)}</span>
            <span class="item__sub">${escapeHtml(sub)}</span>
        </span>
        <span class="item__chev">${chevIcon || ICON.chevron}</span>
    `;
    if (onClick) btn.addEventListener('click', onClick);
    animateIn(btn, 10, index * 40, 360);
    return btn;
}

function render(data) {
    const job = resolveJob(data.job) || resolveJob(data.jobLabel) || FALLBACK_JOB;

    applyAccent(job.accent);

    eyebrow.textContent = data.title || 'Dienstkleidung';
    title.textContent = job.name || data.jobLabel || data.title || 'Dienstkleidung';
    jobIcon.innerHTML = job.icon;

    const grade = data.grade && String(data.grade).trim() ? data.grade : '–';
    rankLabel.textContent = grade;

    const outfits = Array.isArray(data.outfits) ? data.outfits : [];
    countEl.textContent = outfits.length
        ? `${outfits.length} ${outfits.length === 1 ? 'Outfit' : 'Outfits'}`
        : '';

    outfitList.innerHTML = '';
    let idx = 0;

    // Restore-Eintrag
    if (data.restoreEnabled) {
        const disabled = !data.restoreAvailable;
        const btn = makeItem({
            icon: ICON.restore,
            label: data.restoreLabel || 'Normale Kleidung anziehen',
            sub: disabled ? 'Noch keine Kleidung gespeichert' : 'Vorherige Kleidung wieder anziehen',
            extraClass: 'item--restore' + (disabled ? ' is-disabled' : ''),
            index: idx++,
            onClick: disabled ? null : () => {
                hideMenu();
                post('restoreClothes');
            }
        });
        outfitList.appendChild(btn);
    }

    // Keine Outfits
    if (!outfits.length) {
        outfitList.appendChild(makeItem({
            icon: ICON.shirt,
            label: 'Keine Outfits',
            sub: 'Für deinen Dienstgrad ist nichts hinterlegt.',
            extraClass: 'item--empty',
            index: idx++
        }));
        return;
    }

    // Outfit-Liste (kaputte/leere Einträge rausfiltern, damit ein einzelner
    // schlechter Datensatz nicht die komplette render()-Funktion abbricht)
    outfits.filter((outfit) => outfit && typeof outfit === 'object').forEach((outfit) => {
        const isActive = !!outfit.active;
        outfitList.appendChild(makeItem({
            icon: isActive ? ICON.success : ICON.shirt,
            label: outfit.label,
            sub: isActive ? 'Bereits angezogen' : 'Outfit anlegen',
            extraClass: isActive ? 'item--active' : '',
            chevIcon: isActive ? '' : undefined,
            index: idx++,
            onClick: isActive ? null : () => {
                hideMenu();
                post('selectOutfit', { id: outfit.id });
            }
        }));
    });
}

/* ---------- Notify ---------- */

const colorCodes = {
    '~r~': '<span class="color-red">',   '~g~': '<span class="color-green">',
    '~b~': '<span class="color-blue">',  '~y~': '<span class="color-yellow">',
    '~p~': '<span class="color-purple">','~o~': '<span class="color-orange">',
    '~w~': '<span class="color-white">', '~s~': '</span>'
};

function formatMessage(message) {
    let out = escapeHtml(message || 'Keine Nachricht gesetzt');
    for (const [code, repl] of Object.entries(colorCodes)) out = out.split(code).join(repl);
    return out;
}

function createNotification(data) {
    const type = ['success', 'error', 'info', 'warning'].includes(data.type) ? data.type : 'info';
    const duration = Number(data.length || data.duration || 8000);
    const position = ['top-right', 'top-left', 'top-center', 'bottom-right', 'bottom-left', 'bottom-center']
        .includes(data.position) ? data.position : 'top-right';

    root.dataset.position = position;

    const notify = document.createElement('div');
    notify.className = `notify ${type}`;
    notify.style.setProperty('--duration', `${duration}ms`);
    notify.innerHTML = `
        <div class="icon-wrapper">${ICON[type] || ICON.info}</div>
        <div class="content"><p class="text">${formatMessage(data.message)}</p></div>
    `;

    root.appendChild(notify);

    const fromX = position.includes('left') ? -24 : position.includes('center') ? 0 : 24;
    animateIn(notify, fromX, 0, 360);

    window.setTimeout(() => {
        notify.classList.add('fadeOut');
        window.setTimeout(() => notify.remove(), 340);
    }, duration);
}

/* ---------- Events ---------- */

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'notify' || (data.type && data.message)) {
        createNotification(data);
        return;
    }
    if (data.action === 'open') {
        try {
            render(data);
        } catch (err) {
            console.error('[job_outfit] Fehler beim Rendern, Menü wird trotzdem geöffnet:', err);
        }
        app.classList.remove('hidden');
        animateIn(menu, 20, 0, 340);
    }
    if (data.action === 'close') {
        hideMenu();
    }
});

closeBtn.addEventListener('click', closeMenu);

app.addEventListener('click', (event) => {
    if (event.target === app) closeMenu();
});

document.addEventListener('keydown', (event) => {
    // Bewusst OHNE hidden-Check: Falls das UI durch einen Render-Fehler oder
    // einen inkonsistenten State hängen bleibt, muss ESC trotzdem
    // zuverlässig den NUI-Fokus freigeben. Ein doppelter post('close')
    // ist harmlos, ein hängender Fokus ohne Escape-Ausweg dagegen nicht.
    if (event.key === 'Escape') closeMenu();
});

