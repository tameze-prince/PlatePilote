import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email } = req.body || {};

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Email invalide' });
  }

  try {
    const sql = neon(process.env.DATABASE_URL);

    await sql`
      INSERT INTO subscribers (email, source)
      VALUES (${email.toLowerCase()}, 'landing')
      ON CONFLICT (email) DO NOTHING
    `;

    return res.status(200).json({ success: true, message: 'Inscription réussie !' });
  } catch (err) {
    console.error('[subscribe]', err);
    return res.status(500).json({ error: 'Erreur serveur. Réessayez plus tard.' });
  }
}
