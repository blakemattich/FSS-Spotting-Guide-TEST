-- PostgreSQL starter schema for FSS Spotting Guide

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE IF NOT EXISTS spot_guides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  spot_name TEXT NOT NULL,
  aliases TEXT[] DEFAULT '{}',
  category TEXT NOT NULL,
  description TEXT,
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  care_code TEXT
);

CREATE TABLE IF NOT EXISTS media_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('image', 'video')),
  url TEXT NOT NULL,
  caption TEXT,
  alt_text TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS guide_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  spot_guide_id UUID NOT NULL REFERENCES spot_guides(id) ON DELETE CASCADE,
  material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'moderate', 'advanced')),
  time_estimate_minutes INT CHECK (time_estimate_minutes > 0),
  tools_needed JSONB NOT NULL DEFAULT '[]'::jsonb,
  chemicals_needed JSONB NOT NULL DEFAULT '[]'::jsonb,
  safety_notes TEXT,
  warnings TEXT,
  escalation_rules TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'reviewed', 'approved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (spot_guide_id, material_id)
);

CREATE TABLE IF NOT EXISTS guide_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guide_variant_id UUID NOT NULL REFERENCES guide_variants(id) ON DELETE CASCADE,
  step_number INT NOT NULL CHECK (step_number > 0),
  instruction TEXT NOT NULL,
  dwell_time_seconds INT CHECK (dwell_time_seconds >= 0),
  media_asset_id UUID REFERENCES media_assets(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (guide_variant_id, step_number)
);

CREATE INDEX IF NOT EXISTS idx_spot_guides_spot_name_trgm
  ON spot_guides USING gin (spot_name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_spot_guides_aliases_gin
  ON spot_guides USING gin (aliases);

CREATE INDEX IF NOT EXISTS idx_guide_variants_lookup
  ON guide_variants (spot_guide_id, material_id, status);

CREATE INDEX IF NOT EXISTS idx_guide_steps_order
  ON guide_steps (guide_variant_id, step_number);
