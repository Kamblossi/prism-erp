# PrismERP Desk Freeze Investigation

## Symptom

After login, Desk loaded and workspace tiles appeared, but clicking workspace tiles caused the browser to become unresponsive. Chrome asked whether to wait or exit the page.

## Root Cause

The PrismERP Desk branding script (`prism_brand_desk.js`) contained aggressive DOM manipulation that caused an infinite mutation loop:

1. A `MutationObserver` watched `document.body` with `subtree: true` and `childList: true`
2. Every DOM mutation triggered `applyDeskBranding()`
3. `applyDeskBranding()` called `replaceVisibleText()` which used `document.createTreeWalker` to scan ALL text nodes in the entire document body
4. Text replacements modified the DOM, triggering the observer again
5. `updateLogoImages()` also changed `img.src` attributes, triggering the observer
6. Each browser repaint from workspace clicks caused a new mutation cascade

This locked up the browser main thread, making the UI unresponsive.

## Fix

The Desk branding script was replaced with a safe minimal version that only:

- Updates favicon once on page load
- Updates document title once (replacing "ERPNext"/"Frappe" with "PrismERP")
- Adds a `prismerp-desk` body class once

It no longer:

- Scans the whole document repeatedly
- Rewrites all visible text
- Observes mutations
- Repeatedly changes image attributes
- Triggers DOM mutation loops

## Source file

`/opt/prismerp/src/prism-brand/prism_brand/public/js/prism_brand_desk.js`

## Runtime materialized assets

The shared `sites/assets/` volume had broken symlinks for `frappe`, `erpnext`, and `prism_brand`. These were replaced with physical copies:

- `/mnt/prismerp-data/docker/volumes/frappe_docker_sites/_data/assets/prism_brand/js/prism_brand_desk.js` (safe version)
- `/mnt/prismerp-data/docker/volumes/frappe_docker_sites/_data/assets/frappe/` (physical copy)
- `/mnt/prismerp-data/docker/volumes/frappe_docker_sites/_data/assets/erpnext/` (physical copy)

## Why symlinks break

In the current Docker architecture, the backend container mounts the `apps` volume, but the frontend Nginx container does not. Symlinks in `sites/assets/` pointing to `apps/*/public` are broken from the frontend perspective. Assets must be physical copies inside the `sites` volume for Nginx to serve them.

## Commands used

1. Inspected `prism_brand_desk.js` for MutationObserver patterns
2. Wrote safe minimal version to canonical source
3. Committed and pushed to `prism-brand` repo
4. Copied safe JS into running frontend container via `docker cp`
5. Replaced broken symlinks with physical asset copies in shared volume
6. Cleared Frappe cache and flushed Redis

## Next step

User should hard-refresh browser with Ctrl+F5 and test:

- `http://dev-erp.prismtechco.com:8080/desk`
- `http://tenant1-dev-erp.prismtechco.com:8080/desk`

If workspace clicks still freeze, inspect browser console errors and network requests next.
