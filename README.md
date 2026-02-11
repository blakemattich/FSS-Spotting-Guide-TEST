# FSS Spotting Guide

A search-first knowledge app for fabric care technicians. The app helps a technician quickly identify a spot/spill on a furnishing and retrieve safe, material-aware, step-by-step removal guidance (with optional image/video references).

## Goal

Build a technician-facing system where users can:

1. Search for a spot/spill (e.g., coffee, ink, red wine, grease).
2. Filter by furnishing/material context (e.g., cotton, wool, polyester, velvet, leather).
3. Get a clear remediation procedure with safety precautions.
4. View optional image/video demonstrations.

---

## Recommended MVP Scope

### User stories

- As a technician, I can type a spot name and get matching removal guides quickly.
- As a technician, I can filter by material so I avoid damaging the furnishing.
- As a technician, I can see required tools/agents before starting.
- As a technician, I can follow step-by-step instructions and know when to stop/escalate.

### MVP feature set

- Spot/spill search (keyword + fuzzy matching).
- Material filter and severity notes.
- Guide detail page:
  - Safety section
  - Required materials/tools
  - Ordered treatment steps
  - Do-not-use warnings
  - Escalation criteria
  - Linked image/video assets
- Admin content entry/edit for guides.

---

## Data Model (starter)

### `spot_guides`

- `id` (uuid)
- `spot_name` (text)
- `aliases` (text[])
- `category` (text) — e.g., tannin, oil, protein, dye
- `description` (text)
- `risk_level` (enum: low|medium|high)
- `created_at`, `updated_at`

### `materials`

- `id` (uuid)
- `name` (text) — e.g., wool, cotton, silk, synthetic blend, leather
- `care_code` (text, optional)

### `guide_variants`

- `id` (uuid)
- `spot_guide_id` (fk)
- `material_id` (fk)
- `difficulty` (enum: easy|moderate|advanced)
- `time_estimate_minutes` (int)
- `tools_needed` (jsonb)
- `chemicals_needed` (jsonb)
- `safety_notes` (text)
- `warnings` (text)
- `escalation_rules` (text)

### `guide_steps`

- `id` (uuid)
- `guide_variant_id` (fk)
- `step_number` (int)
- `instruction` (text)
- `dwell_time_seconds` (int, optional)
- `media_asset_id` (fk, optional)

### `media_assets`

- `id` (uuid)
- `type` (enum: image|video)
- `url` (text)
- `caption` (text)
- `alt_text` (text)

---

## Search Strategy

1. Start with trigram/fuzzy text search on `spot_name` + `aliases`.
2. Add exact boost for canonical names.
3. Allow optional filters: material, category, risk level.
4. Return top 5 results with confidence score and short summary.

---

## Suggested Tech Stack

- **Frontend:** Next.js + TypeScript
- **Backend/API:** Next.js Route Handlers or FastAPI
- **Database:** PostgreSQL
- **Storage:** S3-compatible object storage for media
- **Auth:** Clerk/Auth0/Supabase Auth (if needed)
- **Hosting:** Vercel (app) + managed Postgres

This can be swapped based on your team preferences.

---

## Safety and Quality Requirements

- Every guide should include explicit “Do not use on…” warnings.
- Material-specific variants are required before publishing a guide.
- Add content review workflow (draft → reviewed → approved).
- Keep version history for guide changes.
- Add legal disclaimer and escalation-to-specialist instructions.

---

## API Outline (example)

- `GET /api/spots?query=coffee&material=wool`
  - returns ranked guide summaries
- `GET /api/spots/:id?material=wool`
  - returns full variant with ordered steps and media
- `POST /api/admin/spots`
  - create guide (admin only)
- `PATCH /api/admin/spots/:id`
  - update guide (admin only)

---

## Build Plan (phased)

### Phase 1: Foundation

- Set up project scaffold and database schema.
- Seed with 25–50 common spots.
- Implement search + guide detail pages.

### Phase 2: Content Operations

- Build admin UI for guide management.
- Add draft/review/approved workflow.
- Add media upload and linking.

### Phase 3: Field Optimization

- Offline-friendly caching for low-connectivity sites.
- Add telemetry (most searched spots, failed searches).
- Add quick “call specialist” workflow.

---

## Example Technician Output

**Spot:** Coffee

**Material:** Wool upholstery

**Risk level:** Medium

1. Blot immediately with clean white towel (no rubbing).
2. Apply pH-neutral spotting solution to towel, then dab stain edge-to-center.
3. Wait 60 seconds; blot dry.
4. Rinse area lightly with water-damp towel and blot.
5. If ring remains, repeat once only.

**Do not use:** high-alkaline cleaner, bleach, aggressive brushing.

**Escalate if:** color transfer, fiber distortion, or stain persists after 2 cycles.

---

## Next Step

If you want, I can generate a full starter implementation next (database schema SQL + API routes + simple web UI) in this repository.
