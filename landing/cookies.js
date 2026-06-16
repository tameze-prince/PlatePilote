/**
 * PlatePilote — Bandeau de consentement cookies (RGPD)
 * 4 catégories : essentiels, analytics, marketing, personnalisation
 * Persistance localStorage — période de 13 mois
 */
(function () {
  'use strict';

  const STORAGE_KEY = 'platepilote_cookie_consent';
  const EXPIRY_DAYS = 395; // ~13 mois

  /* ---- Catégories ---- */
  const CATEGORIES = [
    { id: 'essentiels',       label: 'Essentiels',       desc: 'Nécessaires au fonctionnement du site (session, sécurité). Ne peuvent pas être désactivés.', required: true },
    { id: 'analytics',        label: 'Analytics',        desc: 'Mesure d\'audience anonymisée pour améliorer le service.', required: false },
    { id: 'marketing',        label: 'Marketing',        desc: 'Publicités ciblées et mesure des campagnes.', required: false },
    { id: 'personnalisation', label: 'Personnalisation',  desc: 'Mémorisation de vos préférences (langue, thème, régime).', required: false },
  ];

  /* ---- Lecture / écriture localStorage ---- */
  function loadConsent() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return null;
      const data = JSON.parse(raw);
      // Vérifie si expiré
      if (Date.now() > data.expires) {
        localStorage.removeItem(STORAGE_KEY);
        return null;
      }
      return data;
    } catch {
      return null;
    }
  }

  function saveConsent(choices) {
    const data = {
      version: 1,
      created: Date.now(),
      expires: Date.now() + EXPIRY_DAYS * 24 * 60 * 60 * 1000,
      choices: {},
    };
    CATEGORIES.forEach((cat) => {
      data.choices[cat.id] = choices[cat.id] || false;
    });
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  }

  /* ---- Construction du bandeau ---- */
  function buildBanner() {
    // Évite le flash si déjà consenti
    if (loadConsent()) return;

    // Overlay
    const overlay = document.createElement('div');
    overlay.id = 'cookie-overlay';
    overlay.style.cssText = `
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.55); z-index: 999998;
    `;

    // Bandeau
    const banner = document.createElement('div');
    banner.id = 'cookie-banner';
    banner.style.cssText = `
      position: fixed; bottom: 0; left: 0; width: 100%;
      z-index: 999999; padding: 0;
      display: flex; justify-content: center;
    `;

    const card = document.createElement('div');
    card.style.cssText = `
      max-width: 720px; width: 100%; margin: 16px;
      background: linear-gradient(135deg, #1c1c24, #14141a);
      border: 1px solid rgba(63,63,70,0.6);
      border-radius: 16px; padding: 28px 32px;
      box-shadow: 0 16px 48px rgba(0,0,0,0.5);
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      color: #e4e4e7; line-height: 1.5;
    `;

    // Titre
    const title = document.createElement('p');
    title.style.cssText = 'font-size: 1rem; font-weight: 600; color: #fff; margin-bottom: 4px;';
    title.textContent = '🍪 Paramètres des cookies';
    card.appendChild(title);

    const subtitle = document.createElement('p');
    subtitle.style.cssText = 'font-size: 0.85rem; color: #a1a1aa; margin-bottom: 16px;';
    subtitle.innerHTML = 'Choisissez les catégories de cookies que vous acceptez. <a href="/cookies.html" style="color:#a78bfa;text-decoration:underline;">En savoir plus</a>.';
    card.appendChild(subtitle);

    // Checkboxes
    const checkboxes = {};
    CATEGORIES.forEach((cat) => {
      const row = document.createElement('label');
      row.style.cssText = `
        display: flex; align-items: flex-start; gap: 10px;
        padding: 8px 0; cursor: pointer; border-bottom: 1px solid rgba(63,63,70,0.15);
      `;
      if (cat.required) row.style.opacity = '0.6';

      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.checked = cat.required ? true : false;
      checkbox.disabled = cat.required;
      checkbox.style.cssText = `
        margin-top: 3px; accent-color: #7c3aed;
        width: 16px; height: 16px;
      `;
      checkbox.dataset.catId = cat.id;
      checkboxes[cat.id] = checkbox;

      const textWrap = document.createElement('div');
      const label = document.createElement('span');
      label.style.cssText = 'font-size: 0.9rem; font-weight: 500; color: #fff;';
      label.textContent = cat.label + (cat.required ? ' (requis)' : '');
      const desc = document.createElement('div');
      desc.style.cssText = 'font-size: 0.8rem; color: #71717a; margin-top: 1px;';
      desc.textContent = cat.desc;

      textWrap.appendChild(label);
      textWrap.appendChild(desc);
      row.appendChild(checkbox);
      row.appendChild(textWrap);
      card.appendChild(row);
    });

    // Boutons
    const btnRow = document.createElement('div');
    btnRow.style.cssText = `
      display: flex; gap: 12px; flex-wrap: wrap;
      justify-content: flex-end; margin-top: 20px;
    `;

    function makeBtn(text, primary, onClick) {
      const btn = document.createElement('button');
      btn.textContent = text;
      btn.style.cssText = `
        padding: 10px 24px; border-radius: 10px; border: none;
        font-size: 0.9rem; font-weight: 600; cursor: pointer;
        font-family: inherit; white-space: nowrap;
        transition: transform 0.15s, box-shadow 0.2s;
        ${primary
          ? 'background: linear-gradient(135deg, #7c3aed, #3b82f6); color: #fff;'
          : 'background: rgba(63,63,70,0.5); color: #e4e4e7; border: 1px solid rgba(63,63,70,0.4);'}
      `;
      btn.addEventListener('click', onClick);
      btn.addEventListener('mouseenter', () => { btn.style.transform = 'translateY(-1px)'; });
      btn.addEventListener('mouseleave', () => { btn.style.transform = 'translateY(0)'; });
      return btn;
    }

    // "Tout accepter" — coche tout et valide
    btnRow.appendChild(makeBtn('Tout accepter', true, () => {
      const allOn = {};
      CATEGORIES.forEach((c) => { allOn[c.id] = true; });
      saveConsent(allOn);
      dismiss();
    }));

    // "Personnaliser" — valide uniquement ce qui est coché
    btnRow.appendChild(makeBtn('Personnaliser', false, () => {
      const choices = {};
      CATEGORIES.forEach((c) => {
        choices[c.id] = checkboxes[c.id] ? checkboxes[c.id].checked : false;
      });
      saveConsent(choices);
      dismiss();
    }));

    // "Tout refuser" — ne garde que les essentiels
    btnRow.appendChild(makeBtn('Tout refuser', false, () => {
      const allOff = {};
      CATEGORIES.forEach((c) => { allOff[c.id] = c.required; });
      saveConsent(allOff);
      dismiss();
    }));

    card.appendChild(btnRow);
    banner.appendChild(card);

    // Insertion dans le DOM
    document.body.appendChild(overlay);
    document.body.appendChild(banner);
  }

  function dismiss() {
    const overlay = document.getElementById('cookie-overlay');
    const banner = document.getElementById('cookie-banner');
    if (overlay) overlay.remove();
    if (banner) banner.remove();
  }

  /* ---- Initialisation différée (ne bloque pas le rendu) ---- */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', buildBanner);
  } else {
    buildBanner();
  }
})();