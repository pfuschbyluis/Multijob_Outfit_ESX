/* ============================================================
   Dienstkleidung – Admin-Panel · Logik
   ============================================================ */

(function () {
    // Wichtig: NICHT auf window.location.hostname === 'nui-game-internal' verlassen.
    // Der Hostname ist beim Parsen dieses Scripts wegen einer CEF-Race-Condition
    // teils noch nicht gesetzt, wodurch IN_FIVEM dauerhaft auf false und
    // resourceName auf dem 'preview'-Fallback hängen bleibt (-> POSTs gehen ins Leere,
    // z.B. https://preview/admin:save statt https://dienstkleidung/admin:save).
    // GetParentResourceName() wird von CEF zuverlässig injiziert, sobald wir
    // wirklich im Spiel laufen - das ist der robustere Indikator.
    let resourceName = 'preview';
    let IN_FIVEM = false;
    try {
        if (typeof GetParentResourceName === 'function') {
            resourceName = GetParentResourceName();
            IN_FIVEM = true;
        }
    } catch (e) {
        resourceName = 'ERROR_' + e.message;
    }

    let DEBUG = false;

    function dbg(...args) {
        if (DEBUG) console.log('[dienstkleidung:admin]', ...args);
    }

    function post(name, data = {}) {
        const url = `https://${resourceName}/${name}`;
        dbg('POST ->', url);
        if (!IN_FIVEM) return Promise.resolve();
        return fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data)
        })
            .then((res) => { dbg('POST ok <-', name, res.status); return res; })
            .catch((err) => console.error('[dienstkleidung:admin] NUI-Post FEHLGESCHLAGEN:', url, err && err.message));
    }

    const app = document.getElementById('adminApp');
    const overlay = app.querySelector('.admin__overlay');
    const body = document.getElementById('adminBody');
    const tabsNav = document.getElementById('adminTabs');
    const closeBtn = document.getElementById('adminCloseBtn');
    const cancelBtn = document.getElementById('adminCancelBtn');
    const saveBtn = document.getElementById('adminSaveBtn');
    const adminFoot = document.querySelector('.admin__foot');

    const TAB_META = {
        general: {
            title: 'Allgemein',
            desc: 'Grundlegende Einstellungen für Menü, Kleidungssystem und Zivilkleidung.'
        },
        notify: {
            title: 'Benachrichtigungen',
            desc: 'Steuert, wie Spieler über Aktionen im Outfit-Menü informiert werden.'
        },
        jobs: {
            title: 'Jobs',
            desc: 'Lege fest, welche Jobs das Outfit-Menü nutzen und Outfit-Peds spawnen dürfen.'
        },
        outfits: {
            title: 'Outfits',
            desc: 'Verwalte Kleidung pro Job und Rang. Änderungen werden direkt im Editor gespeichert.'
        },
        peds: {
            title: 'Outfit-Peds',
            desc: 'Konfiguriere NPCs, über die Spieler das Outfit-Menü öffnen können.'
        },
        interaction: {
            title: 'Interaktion',
            desc: 'Bestimme, ob Spieler per Taste oder ox_target mit Outfit-Peds interagieren.'
        }
    };

    let state = null;
    let jobKeys = [];
    let configuredJobs = {};
    let activeTab = 'general';
    let pendingAddPedJob = null;

    // Muss exakt zu componentSlots/propSlots in client.lua passen.
    const CLOTHES_SLOTS = [
        { key: 'mask', label: 'Maske' },
        { key: 'tshirt', label: 'Unterhemd' },
        { key: 'torso', label: 'Oberteil' },
        { key: 'arms', label: 'Arme' },
        { key: 'pants', label: 'Hose' },
        { key: 'shoes', label: 'Schuhe' },
        { key: 'bags', label: 'Taschen/Rucksack' },
        { key: 'bproof', label: 'Weste' },
        { key: 'decals', label: 'Abzeichen' },
        { key: 'chain', label: 'Kette' },
        { key: 'helmet', label: 'Helm/Hut' },
        { key: 'glasses', label: 'Brille' },
        { key: 'ears', label: 'Ohrringe' },
        { key: 'watches', label: 'Uhr' },
        { key: 'bracelets', label: 'Armband' }
    ];

    // Outfits laufen komplett getrennt vom "state"-Objekt (das ist nur für
    // settings.json). Outfits werden pro Job on-demand von der DB geladen.
    let outfitsUi = {
        selectedJob: null,
        list: [],
        loading: false,
        editing: null // { id, grade, label, male: {...}, female: {...} } oder null
    };

    function escapeAttr(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
    }

    function capitalize(str) {
        return String(str || '').charAt(0).toUpperCase() + String(str || '').slice(1);
    }

    function wrapTab(content) {
        const meta = TAB_META[activeTab] || TAB_META.general;
        return `
        <div class="tab-page">
            <header class="tab-page__head">
                <h2 class="tab-page__title">${meta.title}</h2>
                <p class="tab-page__desc">${meta.desc}</p>
            </header>
            ${content}
        </div>`;
    }

    function checkboxField(id, path, label, checked, compact) {
        const safeId = escapeAttr(id);
        const safePath = escapeAttr(path);
        const compactClass = compact ? ' field--checkbox-compact' : '';
        return `
        <label class="field field--checkbox${compactClass}" for="${safeId}">
            <input type="checkbox" id="${safeId}" data-path="${safePath}" ${checked ? 'checked' : ''}>
            <span>${escapeAttr(label)}</span>
        </label>`;
    }

    function isPedEnabled(ped) {
        return !!(ped && ped.enabled !== false);
    }

    function isJobAllowed(s, key) {
        return !!(s && s.AllowedJobs && s.AllowedJobs[key]);
    }

    function enableJobForPed(key) {
        if (!state || !key) return;
        state.AllowedJobs = state.AllowedJobs || {};
        state.AllowedJobs[key] = true;
    }

    function isMarkerMode(s) {
        return !!(s && s.PedSettings && s.PedSettings.displayMode === 'markers');
    }

    function pedToggleControl(key, ped, s) {
        const safeKey = escapeAttr(key);
        const enabled = isPedEnabled(ped);
        const jobAllowed = isJobAllowed(s, key);
        const markerMode = isMarkerMode(s);
        const btnLabel = enabled ? 'Deaktivieren' : 'Aktivieren';
        const statusLabel = enabled ? 'Aktiv' : 'Inaktiv';
        const statusClass = enabled ? 'is-active' : 'is-inactive';
        const btnClass = enabled ? 'btn--deactivate' : 'btn--activate';
        const hint = enabled
            ? (jobAllowed
                ? (markerMode
                    ? 'Nach dem Speichern erscheint an den Koordinaten ein Marker (ohne NPC).'
                    : 'Der NPC wird nach dem Speichern an den Koordinaten gespawnt.')
                : (markerMode
                    ? 'Achtung: Der Job ist unter „Jobs“ deaktiviert – der Marker erscheint erst, wenn der Job erlaubt ist.'
                    : 'Achtung: Der Job ist unter „Jobs“ deaktiviert – der Ped spawnt erst, wenn der Job erlaubt ist.'))
            : (markerMode
                ? 'Aktiviert den Marker und den zugehörigen Job. Nach dem Speichern erscheint die Position in der Welt.'
                : 'Aktiviert den NPC und den zugehörigen Job. Nach dem Speichern erscheint der Ped an den Koordinaten.');
        const title = enabled
            ? (markerMode
                ? 'Marker deaktivieren – die Position erscheint nicht mehr in der Welt'
                : 'Ped deaktivieren – der NPC erscheint nicht mehr in der Welt')
            : (markerMode
                ? 'Marker aktivieren – aktiviert auch den Job und zeigt die Position nach dem Speichern'
                : 'Ped aktivieren – aktiviert auch den Job und spawnt den NPC nach dem Speichern');

        return `
        <div class="ped-toggle">
            <div class="ped-toggle__row">
                <span class="ped-status ${statusClass}">${statusLabel}</span>
                <button type="button" class="btn btn--sm ${btnClass}" data-toggle-ped="${safeKey}" title="${escapeAttr(title)}">${btnLabel}</button>
            </div>
            ${enabled && !jobAllowed ? '<span class="ped-job-warn">Job ist deaktiviert – wird beim Aktivieren automatisch erlaubt</span>' : ''}
            <p class="ped-toggle__hint">${escapeAttr(hint)}</p>
        </div>`;
    }

    // Native <select>-Popups werden von FiveMs CEF teils komplett weiß/ungestylt
    // dargestellt (bekannte Einschränkung). Deshalb ein eigenes, voll gestyltes
    // Dropdown statt <select>/<option>.
    function customSelect(path, options, current, labels) {
        const opts = options.map((o, i) => `
            <button type="button" class="xselect__option ${o === current ? 'is-selected' : ''}" data-select-value="${escapeAttr(o)}">${escapeAttr((labels && labels[i]) || o)}</button>
        `).join('');
        const currentIndex = options.indexOf(current);
        const currentLabel = currentIndex >= 0 && labels ? labels[currentIndex] : current;
        return `
        <div class="xselect" data-select-path="${escapeAttr(path)}">
            <button type="button" class="xselect__trigger" data-select-trigger>${escapeAttr(currentLabel)}</button>
            <div class="xselect__list">${opts}</div>
        </div>`;
    }

    function getPath(obj, path) {
        return path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), obj);
    }

    function setPath(obj, path, value) {
        const parts = path.split('.');
        let cur = obj;
        for (let i = 0; i < parts.length - 1; i++) {
            const k = parts[i];
            if (cur[k] == null || typeof cur[k] !== 'object') cur[k] = {};
            cur = cur[k];
        }
        cur[parts[parts.length - 1]] = value;
    }

    /* ---------- Tab renderers ---------- */

    function renderGeneral(s) {
        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">Grundeinstellungen</div>
            <div class="admin-grid">
                ${checkboxField('f_debug', 'Debug', 'Debug-Ausgaben', s.Debug)}
                <div class="field">
                    <label>Menü-Typ</label>
                    ${customSelect('MenuType', ['custom', 'ox_lib'], s.MenuType)}
                </div>

                <div class="field">
                    <label>Kleidungssystem</label>
                    ${customSelect('ClothingSystem', ['skinchanger', 'native'], s.ClothingSystem)}
                </div>
                ${checkboxField('f_restore', 'EnableRestoreClothes', 'Zivilkleidung wiederherstellen erlauben', s.EnableRestoreClothes)}

                <div class="field span-2">
                    <label>Label „Normale Kleidung anziehen“</label>
                    <input type="text" data-path="RestoreClothesLabel" value="${escapeAttr(s.RestoreClothesLabel)}">
                </div>
            </div>
        </div>
        <div class="admin-section">
            <div class="admin-section__title">Darstellung</div>
            <div class="admin-grid admin-grid--single">
                ${checkboxField('f_anim', 'EnableUiAnimations', 'Öffnungs-Animationen (Outfit-Menü & Admin-Panel)', s.EnableUiAnimations !== false)}
                <p class="help-text">Deaktivieren für sofortiges Öffnen ohne Slide/Fade – hilfreich bei empfindlichen Spielern oder schwächeren PCs.</p>
            </div>
        </div>`);
    }

    function renderNotify(s) {
        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">Notify-Einstellungen</div>
            <p class="help-text">Der Notify-Titel wird als Überschrift angezeigt, die eigentliche Meldung als Beschreibung darunter.</p>
            <div class="admin-grid">
                <div class="field">
                    <label>Notify-System</label>
                    ${customSelect('Notify', ['standard', 'esx', 'ox_lib', 'okok', 'mythic', 'codem', 'qs'], s.Notify)}
                </div>
                <div class="field">
                    <label>Position (nur bei „standard“)</label>
                    ${customSelect('NotifyPosition',
                        ['top-right', 'top-left', 'top-center', 'bottom-right', 'bottom-left', 'bottom-center'],
                        s.NotifyPosition
                    )}
                </div>

                <div class="field">
                    <label>Notify-Titel</label>
                    <input type="text" data-path="NotifyTitle" value="${escapeAttr(s.NotifyTitle)}">
                </div>
                <div class="field">
                    <label>Notify-Dauer (ms)</label>
                    <input type="number" min="500" step="500" data-path="NotifyDuration" value="${s.NotifyDuration}">
                </div>
            </div>
        </div>`);
    }

    function pedCard(key, ped, s) {
        const c = ped.coords || { x: 0, y: 0, z: 0, w: 0 };
        const safeKey = escapeAttr(key);
        const safeLabelKey = escapeAttr(capitalize(key));
        const markerMode = isMarkerMode(s);
        const modelFields = markerMode ? '' : `
            <div class="admin-grid">
                <div class="field">
                    <label>Ped-Model</label>
                    <input type="text" data-path="JobPeds.${safeKey}.model" value="${escapeAttr(ped.model || '')}">
                </div>
                <div class="field">
                    <label>Szenario (optional)</label>
                    <input type="text" data-path="JobPeds.${safeKey}.scenario" value="${escapeAttr(ped.scenario || '')}">
                </div>
                <div class="field span-2">
                    <label>Label</label>
                    <input type="text" data-path="JobPeds.${safeKey}.label" value="${escapeAttr(ped.label || '')}">
                </div>
            </div>`;
        const labelField = markerMode ? `
            <div class="admin-grid admin-grid--single">
                <div class="field">
                    <label>Label (Tasten-Interaktion)</label>
                    <input type="text" data-path="JobPeds.${safeKey}.label" value="${escapeAttr(ped.label || '')}">
                </div>
            </div>` : '';
        return `
        <div class="ped-card" data-ped-job="${safeKey}">
            <div class="ped-card__head">
                <div class="ped-card__title-wrap">
                    <h3>${safeLabelKey}</h3>
                    ${isPedEnabled(ped) && !isJobAllowed(s, key) ? '<span class="ped-job-warn">Job deaktiviert</span>' : ''}
                </div>
                <div class="ped-card__actions">
                    ${pedToggleControl(key, ped, s)}
                    <button type="button" class="btn btn--danger btn--sm" data-remove-ped="${safeKey}" title="${markerMode ? 'Marker-Position für diesen Job vollständig entfernen' : 'Ped-Konfiguration für diesen Job vollständig entfernen'}">Entfernen</button>
                </div>
            </div>
            ${modelFields}
            ${labelField}
            <div class="ped-card__coords">
                <div class="field"><label>X</label><input type="number" step="0.01" data-path="JobPeds.${safeKey}.coords.x" value="${c.x}"></div>
                <div class="field"><label>Y</label><input type="number" step="0.01" data-path="JobPeds.${safeKey}.coords.y" value="${c.y}"></div>
                <div class="field"><label>Z</label><input type="number" step="0.01" data-path="JobPeds.${safeKey}.coords.z" value="${c.z}"></div>
                <div class="field"><label>Heading</label><input type="number" step="0.1" data-path="JobPeds.${safeKey}.coords.w" value="${c.w}"></div>
            </div>
            <div class="ped-card__coords-action">
                <button type="button" class="btn btn--sm" data-use-position="${safeKey}">Aktuelle Position übernehmen</button>
            </div>
        </div>`;
    }

    function renderJobs(s) {
        const allowedHtml = jobKeys.map(k => {
            const isConfigured = configuredJobs[k] !== false;
            const safeKey = escapeAttr(k);
            return `
            <label class="job-toggle ${isConfigured ? '' : 'is-unconfigured'}">
                <div class="job-toggle__top">
                    <input type="checkbox" data-path="AllowedJobs.${safeKey}" ${s.AllowedJobs[k] ? 'checked' : ''}>
                    <span class="job-toggle__name">${escapeAttr(capitalize(k))}</span>
                </div>
                ${isConfigured ? '' : '<span class="job-badge-warn" title="Für diesen Job sind keine Kleidungsdaten hinterlegt">Nicht konfiguriert</span>'}
            </label>`;
        }).join('');

        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">Erlaubte Jobs</div>
            <p class="help-text">
                Deaktivierte Jobs können das Menü nicht öffnen, ihr Outfit-Ped wird nicht gespawnt.
                Jobs mit „nicht konfiguriert“ haben nur leere Platzhalter-Outfits in config.lua – dort fehlt noch die eigentliche Kleidung.
            </p>
            <div class="job-toggle-grid">${allowedHtml || '<div class="empty-state">Keine Jobs mit hinterlegten Outfits gefunden.</div>'}</div>
        </div>`);
    }

    function renderPeds(s) {
        const markerMode = isMarkerMode(s);
        const displayMode = s.PedSettings.displayMode === 'markers' ? 'markers' : 'peds';
        const pedKeys = Object.keys(s.JobPeds || {});
        const pedsHtml = pedKeys.length
            ? pedKeys.map(k => pedCard(k, s.JobPeds[k], s)).join('')
            : `<div class="empty-state">${markerMode ? 'Noch keine Marker-Positionen konfiguriert.' : 'Noch keine Outfit-Peds konfiguriert.'}</div>`;

        const availableForAdd = jobKeys.filter(k => !pedKeys.includes(k));
        const addRow = availableForAdd.length ? `
            <div class="add-ped-row">
                ${customSelect(
                    '__addPedJob',
                    availableForAdd,
                    availableForAdd.includes(pendingAddPedJob) ? pendingAddPedJob : availableForAdd[0],
                    availableForAdd.map(capitalize)
                )}
                <button type="button" class="btn" id="addPedBtn">${markerMode ? '+ Marker hinzufügen' : '+ Ped hinzufügen'}</button>
            </div>` : '';

        const pedBehaviorSection = markerMode ? '' : `
        <div class="admin-section">
            <div class="admin-section__title">Ped-Verhalten (gilt für alle NPCs)</div>
            <div class="admin-grid admin-grid--narrow">
                ${checkboxField('ped_freeze', 'PedSettings.freeze', 'Eingefroren', s.PedSettings.freeze)}
                ${checkboxField('ped_invincible', 'PedSettings.invincible', 'Unverwundbar', s.PedSettings.invincible)}
                ${checkboxField('ped_block', 'PedSettings.blockEvents', 'Reagiert nicht auf Umgebung', s.PedSettings.blockEvents)}
            </div>
        </div>`;

        const markerSettingsSection = markerMode ? `
        <div class="admin-section">
            <div class="admin-section__title">Marker-Einstellungen</div>
            <p class="help-text">Im Marker-Modus werden keine NPCs gespawnt – nur Boden-Marker an den hinterlegten Positionen.</p>
            <div class="admin-grid">
                ${checkboxField('ped_blip', 'PedSettings.showBlip', 'Karten-Blips für Marker-Positionen', s.PedSettings.showBlip)}
                <div class="field">
                    <label>Marker-Sichtweite (Meter)</label>
                    <input type="number" min="5" step="1" data-path="PedSettings.markerDrawDistance" value="${s.PedSettings.markerDrawDistance ?? 30}">
                </div>
            </div>
        </div>` : '';

        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">Anzeige in der Welt</div>
            <p class="help-text">Entweder Outfit-NPCs <strong>oder</strong> Marker an den Positionen – nicht beides gleichzeitig.</p>
            <div class="admin-grid admin-grid--single">
                <div class="field">
                    <label>Modus</label>
                    ${customSelect(
                        'PedSettings.displayMode',
                        ['peds', 'markers'],
                        displayMode,
                        ['Outfit-Peds (NPCs)', 'Marker (ohne NPCs)']
                    )}
                </div>
            </div>
        </div>
        <div class="admin-section">
            <div class="admin-section__title">${markerMode ? 'Marker-Positionen' : 'Konfigurierte Peds'}</div>
            ${pedsHtml}
            ${addRow}
        </div>
        ${pedBehaviorSection}
        ${markerSettingsSection}`);
    }

    function renderInteraction(s) {
        const keySection = s.Interaction === 'key' ? `
        <div class="admin-section">
            <div class="admin-section__title">Tasten-Interaktion</div>
            <div class="admin-grid admin-grid--narrow">
                <div class="field"><label>Distanz</label><input type="number" step="0.1" data-path="KeyInteract.distance" value="${s.KeyInteract.distance}"></div>
                <div class="field"><label>Sichtweite</label><input type="number" step="0.1" data-path="KeyInteract.drawDistance" value="${s.KeyInteract.drawDistance}"></div>
                <div class="field"><label>Taste (Control-ID)</label><input type="number" data-path="KeyInteract.key" value="${s.KeyInteract.key}"></div>
                <div class="span-3">${checkboxField('key_allowed', 'KeyInteract.onlyShowForAllowedJobs', 'Nur für berechtigte Jobs anzeigen', s.KeyInteract.onlyShowForAllowedJobs)}</div>
            </div>
        </div>` : `
        <div class="admin-section">
            <div class="admin-section__title">Target-Interaktion</div>
            <div class="admin-grid">
                <div class="field"><label>Distanz</label><input type="number" step="0.1" data-path="Target.distance" value="${s.Target.distance}"></div>
                <div class="field"><label>Icon (FontAwesome-Klasse)</label><input type="text" data-path="Target.icon" value="${escapeAttr(s.Target.icon)}"></div>
                <div class="field span-2"><label>Label</label><input type="text" data-path="Target.label" value="${escapeAttr(s.Target.label)}"></div>
            </div>
        </div>`;

        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">Interaktionsart</div>
            <div class="admin-grid admin-grid--single">
                <div class="field">
                    <label>Modus</label>
                    ${customSelect('Interaction', ['key', 'ox_target'], s.Interaction)}
                </div>
            </div>
        </div>
        ${keySection}`);
    }

    function clothesGrid(prefix, clothes) {
        clothes = clothes || {};
        const rows = CLOTHES_SLOTS.map(slot => {
            const d = clothes[slot.key + '_1'];
            const t = clothes[slot.key + '_2'];
            return `
            <div class="clothes-row">
                <span class="clothes-row__label">${escapeAttr(slot.label)}</span>
                <input type="number" class="clothes-input" data-clothes-path="${prefix}.${slot.key}_1" placeholder="Drawable" value="${d === undefined || d === null ? '' : d}">
                <input type="number" class="clothes-input" data-clothes-path="${prefix}.${slot.key}_2" placeholder="Textur" value="${t === undefined || t === null ? '' : t}">
            </div>`;
        }).join('');

        return `<div class="clothes-grid">
            <div class="clothes-row clothes-row--head">
                <span></span><span>Drawable</span><span>Textur</span>
            </div>
            ${rows}
        </div>`;
    }

    function outfitEditor(outfit) {
        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">${outfit.id ? 'Outfit bearbeiten' : 'Neues Outfit'} — ${escapeAttr(capitalize(outfitsUi.selectedJob))}</div>
            <div class="admin-grid">
                <div class="field"><label>Rang (Grade-Nummer)</label><input type="number" data-outfit-field="grade" value="${outfit.grade}"></div>
                <div class="field span-2"><label>Bezeichnung</label><input type="text" data-outfit-field="label" value="${escapeAttr(outfit.label)}"></div>
            </div>
        </div>
        <div class="outfit-editor-cols">
            <div class="outfit-editor-col">
                <div class="admin-section__title">Männlich</div>
                ${clothesGrid('male', outfit.male)}
            </div>
            <div class="outfit-editor-col">
                <div class="admin-section__title">Weiblich</div>
                ${clothesGrid('female', outfit.female)}
            </div>
        </div>
        <div class="outfit-editor-actions">
            <button type="button" class="btn btn--sm" id="outfitCopyBtn">Männlich → Weiblich kopieren</button>
            <button type="button" class="btn btn--sm" id="outfitPreviewBtn">Vorschau anziehen</button>
            <span class="outfit-editor-spacer"></span>
            ${outfit.id ? '<button type="button" class="btn btn--danger btn--sm" id="outfitDeleteBtn">Löschen</button>' : ''}
            <button type="button" class="btn btn--sm" id="outfitCancelBtn">Abbrechen</button>
            <button type="button" class="btn btn--primary btn--sm" id="outfitSaveBtn">Speichern</button>
        </div>`);
    }

    function renderOutfits() {
        if (outfitsUi.editing) {
            return outfitEditor(outfitsUi.editing);
        }

        const selectedJob = outfitsUi.selectedJob || jobKeys[0] || null;

        const rows = outfitsUi.loading
            ? '<div class="empty-state">Lade Outfits …</div>'
            : (outfitsUi.list.length
                ? outfitsUi.list.map(o => `
                    <div class="outfit-row">
                        <span class="outfit-row__grade">Rang ${escapeAttr(o.grade)}</span>
                        <span class="outfit-row__label">${escapeAttr(o.label)}</span>
                        <button type="button" class="btn btn--sm" data-edit-outfit="${o.id}">Bearbeiten</button>
                    </div>`).join('')
                : '<div class="empty-state">Noch keine Outfits für diesen Job.</div>');

        return wrapTab(`
        <div class="admin-section">
            <div class="admin-section__title">Outfit-Liste</div>
            <div class="info-banner">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
                <span>Outfits werden pro Job und Rang verwaltet. Der Rang muss mit dem tatsächlichen ESX-Job-Grade des Spielers übereinstimmen. Änderungen speicherst du direkt im Editor.</span>
            </div>
            <div class="admin-grid admin-grid--single">
                <div class="field">
                    <label>Job</label>
                    ${jobKeys.length ? customSelect('__outfitsJob', jobKeys, selectedJob, jobKeys.map(capitalize)) : '<div class="empty-state">Keine Jobs bekannt.</div>'}
                </div>
            </div>
            <div class="outfit-list">${rows}</div>
            <button type="button" class="btn btn--primary" id="outfitNewBtn" ${selectedJob ? '' : 'disabled'}>+ Neues Outfit</button>
        </div>`);
    }

    function updateFooter() {
        if (!adminFoot) return;
        adminFoot.classList.toggle('is-outfits-mode', activeTab === 'outfits');
    }

    function applyUiAnimations(enabled) {
        document.documentElement.classList.toggle('ui-animations-off', enabled === false);
    }

    function render() {
        if (!state) return;

        applyUiAnimations(state.EnableUiAnimations !== false);

        tabsNav.querySelectorAll('button[data-tab]').forEach(b => b.classList.toggle('is-active', b.dataset.tab === activeTab));
        updateFooter();

        const renderers = {
            general: renderGeneral,
            notify: renderNotify,
            jobs: renderJobs,
            peds: renderPeds,
            interaction: renderInteraction,
            outfits: renderOutfits
        };

        body.innerHTML = (renderers[activeTab] || renderGeneral)(state);

        if (saveErrorMessage) {
            const banner = document.createElement('div');
            banner.id = 'adminSaveError';
            banner.className = 'save-error-banner';
            banner.textContent = saveErrorMessage;
            body.prepend(banner);
        }
    }

    /* ---------- Input handling (delegated, no full re-render for plain fields) ---------- */

    function readInputValue(el) {
        if (el.type === 'checkbox') return el.checked;
        if (el.type === 'number') return el.value === '' ? 0 : parseFloat(el.value);
        return el.value;
    }

    body.addEventListener('input', (e) => {
        const el = e.target;

        if (el.dataset && el.dataset.clothesPath) {
            if (!outfitsUi.editing) return;
            const raw = el.value;
            setPath(outfitsUi.editing, el.dataset.clothesPath, raw === '' ? undefined : parseInt(raw, 10));
            return;
        }

        if (el.dataset && el.dataset.outfitField) {
            if (!outfitsUi.editing) return;
            const field = el.dataset.outfitField;
            outfitsUi.editing[field] = field === 'grade' ? (parseInt(el.value, 10) || 0) : el.value;
            return;
        }

        if (!el.dataset || !el.dataset.path) return;
        if (el.tagName === 'SELECT') return; // handled on change
        setPath(state, el.dataset.path, readInputValue(el));
        if (el.dataset.path === 'EnableUiAnimations') {
            applyUiAnimations(state.EnableUiAnimations !== false);
        }
    });

    body.addEventListener('change', (e) => {
        const el = e.target;

        if (el.dataset && el.dataset.path) {
            setPath(state, el.dataset.path, readInputValue(el));
            if (el.dataset.path === 'EnableUiAnimations') {
                applyUiAnimations(state.EnableUiAnimations !== false);
            }
            if (el.dataset.path.startsWith('AllowedJobs.') && activeTab === 'jobs') {
                render();
            }
            if (el.dataset.path === 'Interaction' && activeTab === 'interaction') {
                render();
            }
        }
    });

    body.addEventListener('click', (e) => {
        const trigger = e.target.closest('[data-select-trigger]');
        if (trigger) {
            const wrap = trigger.closest('.xselect');
            const wasOpen = wrap.classList.contains('is-open');
            body.querySelectorAll('.xselect.is-open').forEach(w => w.classList.remove('is-open', 'is-open-up'));

            if (!wasOpen) {
                wrap.classList.add('is-open');

                const list = wrap.querySelector('.xselect__list');
                const triggerRect = trigger.getBoundingClientRect();
                const bodyRect = body.getBoundingClientRect();
                const spaceBelow = bodyRect.bottom - triggerRect.bottom;
                const listHeight = Math.min(list.scrollHeight, 220) + 8;

                if (spaceBelow < listHeight) {
                    wrap.classList.add('is-open-up');
                }
            }
            return;
        }

        const optionBtn = e.target.closest('[data-select-value]');
        if (optionBtn) {
            const wrap = optionBtn.closest('.xselect');
            const path = wrap.dataset.selectPath;
            const value = optionBtn.dataset.selectValue;

            if (path === '__addPedJob') {
                pendingAddPedJob = value;
            } else if (path === '__outfitsJob') {
                fetchOutfitsList(value);
            } else {
                setPath(state, path, value);
            }

            render();
            return;
        }

        const removeKey = e.target.getAttribute && e.target.getAttribute('data-remove-ped');
        if (removeKey) {
            delete state.JobPeds[removeKey];
            render();
            return;
        }

        const toggleBtn = e.target.closest && e.target.closest('[data-toggle-ped]');
        if (toggleBtn) {
            const key = toggleBtn.getAttribute('data-toggle-ped');
            if (key && state.JobPeds && state.JobPeds[key]) {
                const nextEnabled = !isPedEnabled(state.JobPeds[key]);
                state.JobPeds[key].enabled = nextEnabled;
                if (nextEnabled) enableJobForPed(key);
                render();
            }
            return;
        }

        if (e.target.id === 'addPedBtn') {
            const availableForAdd = jobKeys.filter(k => !Object.keys(state.JobPeds || {}).includes(k));
            const key = availableForAdd.includes(pendingAddPedJob) ? pendingAddPedJob : availableForAdd[0];
            if (!key) return;

            enableJobForPed(key);
            state.JobPeds[key] = {
                enabled: true,
                model: '',
                coords: { x: 0.0, y: 0.0, z: 0.0, w: 0.0 },
                scenario: '',
                label: `[E] ${capitalize(key)} Outfit-Menü öffnen`
            };
            pendingAddPedJob = null;
            render();
            return;
        }

        const posKey = e.target.getAttribute && e.target.getAttribute('data-use-position');
        if (posKey) {
            fetchPosition(posKey);
            return;
        }

        const editOutfitId = e.target.getAttribute && e.target.getAttribute('data-edit-outfit');
        if (editOutfitId) {
            const found = outfitsUi.list.find(o => String(o.id) === String(editOutfitId));
            if (found) {
                outfitsUi.editing = JSON.parse(JSON.stringify(found));
                render();
            }
            return;
        }

        if (e.target.id === 'outfitNewBtn') {
            outfitsUi.editing = { id: null, grade: 0, label: '', male: {}, female: {} };
            render();
            return;
        }

        if (e.target.id === 'outfitCancelBtn') {
            outfitsUi.editing = null;
            render();
            return;
        }

        if (e.target.id === 'outfitCopyBtn') {
            if (outfitsUi.editing) {
                outfitsUi.editing.female = JSON.parse(JSON.stringify(outfitsUi.editing.male || {}));
                render();
            }
            return;
        }

        if (e.target.id === 'outfitPreviewBtn') {
            if (outfitsUi.editing) {
                post('admin:outfits:preview', {
                    male: outfitsUi.editing.male || {},
                    female: outfitsUi.editing.female || {}
                });
            }
            return;
        }

        if (e.target.id === 'outfitSaveBtn') {
            if (outfitsUi.editing) {
                post('admin:outfits:save', {
                    id: outfitsUi.editing.id || undefined,
                    jobName: outfitsUi.selectedJob,
                    grade: outfitsUi.editing.grade,
                    label: outfitsUi.editing.label,
                    male: outfitsUi.editing.male || {},
                    female: outfitsUi.editing.female || {}
                });
            }
            return;
        }

        if (e.target.id === 'outfitDeleteBtn') {
            if (outfitsUi.editing && outfitsUi.editing.id) {
                post('admin:outfits:delete', { id: outfitsUi.editing.id, jobName: outfitsUi.selectedJob });
            }
            return;
        }
    });

    document.addEventListener('click', (e) => {
        if (!e.target.closest('.xselect')) {
            body.querySelectorAll('.xselect.is-open').forEach(w => w.classList.remove('is-open', 'is-open-up'));
        }
    });

    // post() gibt bei uns keinen geparsten Wert zurück; für die Positions-Übernahme
    // brauchen wir das echte Callback-Ergebnis, daher ein eigener kleiner Helper.
    function fetchPosition(key) {
        if (!IN_FIVEM) return;

        fetch(`https://${resourceName}/admin:getPosition`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        })
            .then(r => r.json())
            .then(pos => {
                if (!pos) return;
                state.JobPeds[key].coords = { x: pos.x, y: pos.y, z: pos.z, w: pos.w };
                render();
            })
            .catch((err) => console.error('[dienstkleidung:admin] Position konnte nicht abgerufen werden:', err));
    }

    function fetchOutfitsList(jobName) {
        outfitsUi.selectedJob = jobName || null;

        if (!jobName) {
            outfitsUi.list = [];
            outfitsUi.loading = false;
            render();
            return;
        }

        outfitsUi.loading = true;
        render();

        if (!IN_FIVEM) {
            outfitsUi.list = [];
            outfitsUi.loading = false;
            render();
            return;
        }

        fetch(`https://${resourceName}/admin:outfits:list`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ jobName })
        })
            .then(r => r.json())
            .then(list => {
                outfitsUi.list = Array.isArray(list) ? list : [];
                outfitsUi.loading = false;
                render();
            })
            .catch((err) => {
                console.error('[dienstkleidung:admin] Outfits konnten nicht geladen werden:', err);
                outfitsUi.list = [];
                outfitsUi.loading = false;
                render();
            });
    }

    tabsNav.addEventListener('click', (e) => {
        const btn = e.target.closest('button[data-tab]');
        if (!btn) return;
        activeTab = btn.dataset.tab;

        if (activeTab === 'outfits') {
            outfitsUi.editing = null;
            fetchOutfitsList(outfitsUi.selectedJob || jobKeys[0] || null);
            return;
        }

        render();
    });

    let savePending = false;
    let saveErrorMessage = '';

    function setSaveUiState(pending, errorMessage) {
        savePending = pending;
        saveErrorMessage = errorMessage || '';
        if (!saveBtn) return;
        saveBtn.disabled = pending;
        saveBtn.textContent = pending ? 'Speichern…' : 'Speichern';
        const existing = document.getElementById('adminSaveError');
        if (existing) existing.remove();
        if (saveErrorMessage && body) {
            const banner = document.createElement('div');
            banner.id = 'adminSaveError';
            banner.className = 'save-error-banner';
            banner.textContent = saveErrorMessage;
            body.prepend(banner);
        }
    }

    function closePanel() {
        dbg('closePanel()');
        setSaveUiState(false, '');
        app.classList.add('hidden');
        post('admin:close');
    }

    function savePanel() {
        if (savePending || !state) return;
        dbg('savePanel()');
        setSaveUiState(true, '');
        post('admin:save', state);
    }

    closeBtn.addEventListener('click', closePanel);
    cancelBtn.addEventListener('click', closePanel);
    saveBtn.addEventListener('click', savePanel);

    if (overlay) {
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) closePanel();
        });
    }

    document.addEventListener('keydown', (e) => {
        // Kein hidden-Check mehr: gleicher Grund wie im Haupt-NUI-Skript –
        // ESC muss den Fokus auch dann freigeben können, wenn der State
        // durch einen Render-/Datenfehler inkonsistent geworden ist.
        if (e.key === 'Escape') closePanel();
    });

    window.addEventListener('message', (event) => {
        const data = event.data || {};

        if (data.action === 'closeAdmin') {
            app.classList.add('hidden');
            setSaveUiState(false, '');
            return;
        }

        if (data.action === 'adminSaved') {
            setSaveUiState(false, '');
            app.classList.add('hidden');
            return;
        }

        if (data.action === 'adminSaveError') {
            setSaveUiState(false, data.reason || 'Speichern fehlgeschlagen.');
            app.classList.remove('hidden');
            return;
        }

        if (data.action === 'outfitsSaved') {
            outfitsUi.editing = null;
            if (activeTab === 'outfits') fetchOutfitsList(outfitsUi.selectedJob);
            return;
        }

        if (data.action === 'outfitsSaveError') {
            // Editor bleibt offen, damit der Admin die Eingabe korrigieren kann.
            // Die eigentliche Fehlermeldung kommt separat über das normale Notify-System.
            return;
        }

        if (data.action !== 'openAdmin') return;

        DEBUG = !!data.debug;
        dbg('openAdmin empfangen, DEBUG =', DEBUG);
        if (DEBUG) post('debug:ping');
        state = JSON.parse(JSON.stringify(data.settings || {}));
        if (state.EnableUiAnimations === undefined) state.EnableUiAnimations = true;
        applyUiAnimations(state.EnableUiAnimations !== false);
        state.AllowedJobs = state.AllowedJobs || {};
        state.JobPeds = state.JobPeds || {};
        state.PedSettings = state.PedSettings || { freeze: true, invincible: true, blockEvents: true, displayMode: 'peds', showBlip: false, markerDrawDistance: 30 };
        if (state.PedSettings.displayMode !== 'markers' && state.PedSettings.displayMode !== 'peds') {
            state.PedSettings.displayMode = state.PedSettings.showMarker === true ? 'markers' : 'peds';
        }
        delete state.PedSettings.showMarker;
        if (state.PedSettings.showBlip === undefined) state.PedSettings.showBlip = false;
        if (state.PedSettings.markerDrawDistance === undefined) state.PedSettings.markerDrawDistance = 30;
        state.KeyInteract = state.KeyInteract || { distance: 2.5, drawDistance: 12.0, key: 38, onlyShowForAllowedJobs: true };
        state.Target = state.Target || { distance: 2.5, icon: 'fa-solid fa-shirt', label: 'Outfit-Menü öffnen' };
        state.NotifyPosition = state.NotifyPosition || 'top-right';

        const keySet = new Set([
            ...(data.jobKeys || []),
            ...Object.keys(state.AllowedJobs),
            ...Object.keys(state.JobPeds)
        ]);
        jobKeys = Array.from(keySet).sort();
        jobKeys.forEach(k => {
            if (state.AllowedJobs[k] === undefined) {
                state.AllowedJobs[k] = !!(state.JobPeds && state.JobPeds[k] && isPedEnabled(state.JobPeds[k]));
            }
        });
        configuredJobs = data.configuredJobs || {};
        pendingAddPedJob = null;
        outfitsUi = { selectedJob: jobKeys[0] || null, list: [], loading: false, editing: null };

        activeTab = 'general';
        app.classList.remove('hidden');
        try {
            render();
        } catch (err) {
            console.error('[dienstkleidung] Admin-Render-Fehler:', err);
        }
    });
})();
