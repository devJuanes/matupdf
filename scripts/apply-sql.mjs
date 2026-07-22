/**
 * Aplica docs/matudb_schema.sql en MatuDB vía RPC.
 * Uso: node scripts/apply-sql.mjs
 * Requiere MATUDB_URL, MATUDB_PROJECT_ID, MATUDB_API_KEY en el entorno.
 */
import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createClient } from '@devjuanes/matuclient';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');

const url = process.env.MATUDB_URL;
const projectId = process.env.MATUDB_PROJECT_ID;
const apiKey = process.env.MATUDB_SERVICE_KEY || process.env.MATUDB_API_KEY;

if (!url || !projectId || !apiKey) {
  console.error('Faltan MATUDB_URL / MATUDB_PROJECT_ID / MATUDB_API_KEY');
  process.exit(1);
}

const fileArg = process.argv[2];
const sqlFile = fileArg
  ? resolve(fileArg)
  : resolve(root, 'docs/matudb_schema.sql');
const sql = readFileSync(sqlFile, 'utf8').replace(/--[^\n]*/g, '');

const statements = sql
  .split(';')
  .map((s) => s.trim())
  .filter(Boolean);

const db = createClient({ url, projectId, apiKey });

console.log(`Aplicando ${statements.length} statements de matudb_schema.sql…`);

for (let i = 0; i < statements.length; i++) {
  const stmt = `${statements[i]};`;
  const preview = stmt.replace(/\s+/g, ' ').slice(0, 72);
  process.stdout.write(`[${i + 1}/${statements.length}] ${preview}… `);
  const { error } = await db.rpc(stmt);
  if (error) console.log('ERROR:', error.message || JSON.stringify(error));
  else console.log('ok');
}

console.log('Listo.');
