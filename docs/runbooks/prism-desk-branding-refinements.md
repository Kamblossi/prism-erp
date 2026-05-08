# PrismERP Desk Branding Refinements

## Issues Addressed

### Issue A — Workspace sidebar subtitle
The left sidebar header inside workspaces (Organization, Accounting, etc.) showed:
```
Organization
ERPNext
```
The subtitle "ERPNext" needed to be replaced with "PrismERP".

### Issue B — About dialog content
The default Frappe About dialog showed generic Frappe information with links to frappe.io, GitHub, etc. It needed to be replaced with custom PrismERP branding content.

## Implementation

### Workspace subtitle replacement
- Targets only specific elements with selectors like `.sidebar-item-label.header-subtitle`
- Only replaces exact text match "ERPNext" with "PrismERP"
- Runs once on page load and again after route changes (with 200ms and 800ms delays for async rendering)
- Does NOT scan the whole DOM or use MutationObserver

### About dialog override
- Replaces `frappe.ui.misc.about` function (the actual Frappe v16 implementation)
- The original function creates a dialog with Frappe branding; ours creates one with PrismERP branding
- Clears any cached dialog (`frappe.ui.misc.about_dialog = null`) to prevent stale Frappe content from showing
- Always recreates the dialog on each open to ensure fresh PrismERP content
- Content includes: title (PrismERP), description, clickable links (Website, LinkedIn, X, Email), version info, and copyright

## Why the first attempt failed
The initial override targeted `frappe.ui.toolbar.AboutDialog.prototype.show`, but Frappe v16 uses `frappe.ui.misc.about()` (a function, not a class). The correct hook point is `frappe.ui.misc.about`.

## Anti-freeze guarantees
This implementation intentionally avoids:
- MutationObserver watching the whole document
- `document.createTreeWalker` for full-page text scanning
- Repeated DOM rewrites on every mutation
- Recursive image attribute changes
- Broad DOM observation patterns that caused the previous browser freeze

## Source file
`/opt/prismerp/src/prism-brand/prism_brand/public/js/prism_brand_desk.js`

## Runtime asset
`/mnt/prismerp-data/docker/volumes/frappe_docker_sites/_data/assets/prism_brand/js/prism_brand_desk.js`

## Testing checklist
- [ ] Hard refresh browser (Ctrl+Shift+R)
- [ ] Open workspace (e.g., Organization) — sidebar subtitle shows "PrismERP" not "ERPNext"
- [ ] Click Help → About — custom PrismERP content appears with clickable links
- [ ] Close and reopen About dialog — content remains PrismERP (no stale cache)
- [ ] Navigate between workspaces — subtitle remains correct after route changes
- [ ] No browser freeze or unresponsive tab warnings
- [ ] Workspace tiles remain clickable and functional
