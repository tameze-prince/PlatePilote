import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const key = req.headers['x-admin-key'];
  if (!key || key !== process.env.ADMIN_KEY) {
    return res.status(401).json({ error: 'Non autorisé' });
  }

  try {
    const sql = neon(process.env.DATABASE_URL);
    const subscribers = await sql`
      SELECT email, source, subscribed_at
      FROM subscribers
      ORDER BY subscribed_at DESC
      LIMIT 1000
    `;

    return res.status(200).json({ success: true, data: subscribers });
  } catch (err) {
    console.error('[admin]', err);
    return res.status(500).json({ error: 'Erreur serveur.' });
  }
}
