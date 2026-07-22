-- Donaciones / apoyos voluntarios (PayMatuByte)
CREATE TABLE IF NOT EXISTS voluntary_donations (
  id SERIAL PRIMARY KEY,
  payment_reference TEXT NOT NULL,
  link_id TEXT,
  transaction_id TEXT,
  payment_status TEXT,
  is_paid BOOLEAN DEFAULT FALSE,
  amount_cop INTEGER,
  email TEXT,
  user_id TEXT,
  wants_greeting BOOLEAN DEFAULT FALSE,
  source_page TEXT DEFAULT 'web',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS payment_reference TEXT;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS link_id TEXT;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS transaction_id TEXT;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS payment_status TEXT;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS is_paid BOOLEAN DEFAULT FALSE;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS amount_cop INTEGER;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS user_id TEXT;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS wants_greeting BOOLEAN DEFAULT FALSE;
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS source_page TEXT DEFAULT 'web';
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE voluntary_donations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE UNIQUE INDEX IF NOT EXISTS idx_voluntary_donations_reference
  ON voluntary_donations(payment_reference);
CREATE INDEX IF NOT EXISTS idx_voluntary_donations_email ON voluntary_donations(email);
CREATE INDEX IF NOT EXISTS idx_voluntary_donations_created ON voluntary_donations(created_at DESC);
