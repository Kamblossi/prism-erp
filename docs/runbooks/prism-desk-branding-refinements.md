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
The default Frappe About dialog showed generic Frappe/ERPNext information. It needed to be replaced with custom PrismERP branding content.

## Implementation

### Workspace subtitle replacement
- Targets only specific elements with selectors like `.sidebar-item-label.header-subtitle`
- Only replaces exact text match "ERPNext" with "PrismERP"
- Runs once on page load and again after route changes (with 200ms and 800ms delays for async rendering)
- Does NOT scan the whole DOM or use MutationObserver

### About dialog override
- Overrides `frappe.ui.toolbar.AboutDialog.prototype.show` method
- Replaces only the About dialog content with custom PrismERP HTML
- Uses a Frappe `frappe.ui.Dialog` with an HTML field
- Content includes: title, description, clickable links (Website, LinkedIn, X, Email), version info, and copyright
- Does NOT affect other dialogs or modals

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
- [ ] Open workspace (e.g., Organization) — sidebar subtitle shows "PrismERP" not "ERPNext"
- [ ] Click Help / About — custom PrismERP content appears with clickable links
- [ ] Navigate between workspaces — subtitle remains correct after route changes
- [ ] No browser freeze or unresponsive tab warnings
- [ ] Workspace tiles remain clickable and functional
