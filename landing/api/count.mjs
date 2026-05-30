import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const sql = neon(process.env.DATABASE_URL);
    const result = await sql`SELECT COUNT(*)::int AS count FROM subscribers`;
    const count = result[0]?.count ?? 0;

    return res.status(200).json({ success: true, count });
  } catch (err) {
    console.error('[count]', err);
    return res.status(500).json({ error: 'Erreur serveur.' });
  }
}
