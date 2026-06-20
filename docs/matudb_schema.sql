-- =============================================================================
-- MatuPDF — schema completo para MatuDB (PostgreSQL)
-- Ejecutar TODO este script en tu instancia MatuDB.
-- =============================================================================

-- 1. Mensajes de contacto
CREATE TABLE IF NOT EXISTS contact_messages (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT,
  message TEXT NOT NULL,
  user_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE contact_messages ADD COLUMN IF NOT EXISTS subject TEXT;
ALTER TABLE contact_messages ADD COLUMN IF NOT EXISTS user_id TEXT;
ALTER TABLE contact_messages ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Combinaciones / descargas de PDF
CREATE TABLE IF NOT EXISTS pdf_downloads (
  id SERIAL PRIMARY KEY,
  user_id TEXT,
  guest_id TEXT,
  event_type TEXT NOT NULL DEFAULT 'merge',
  file_count INTEGER NOT NULL DEFAULT 1,
  file_names TEXT,
  output_name TEXT,
  storage_path TEXT,
  file_url TEXT,
  platform TEXT DEFAULT 'web',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS user_id TEXT;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS guest_id TEXT;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS event_type TEXT NOT NULL DEFAULT 'merge';
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS file_count INTEGER NOT NULL DEFAULT 1;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS file_names TEXT;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS output_name TEXT;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS storage_path TEXT;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS platform TEXT DEFAULT 'web';
ALTER TABLE pdf_downloads ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

UPDATE pdf_downloads SET event_type = 'merge' WHERE event_type IS NULL;

-- 3. Índices
CREATE INDEX IF NOT EXISTS idx_pdf_downloads_user ON pdf_downloads(user_id);
CREATE INDEX IF NOT EXISTS idx_pdf_downloads_guest ON pdf_downloads(guest_id);
CREATE INDEX IF NOT EXISTS idx_pdf_downloads_event ON pdf_downloads(event_type);
CREATE INDEX IF NOT EXISTS idx_pdf_downloads_created ON pdf_downloads(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_messages_email ON contact_messages(email);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created ON contact_messages(created_at DESC);
