import express from 'express';
import cookieParser from 'cookie-parser';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const app = express();
const PORT = process.env.PORT || 3003;
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend-service:3001';

app.use(cookieParser());
app.use(express.json());

const clientDist = resolve(__dirname, '../../dist');
app.use(express.static(clientDist));

app.get('/b2g/login', (req, res) => {
  res.sendFile(resolve(clientDist, 'index.html'));
});

app.get('/b2g', (req, res) => {
  res.sendFile(resolve(clientDist, 'index.html'));
});

app.get('/b2g/requests', (req, res) => {
  res.sendFile(resolve(clientDist, 'index.html'));
});

app.post('/b2g/login', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });

    if (response.ok) {
      const data = await response.json();
      res.cookie('jwt', data.token, { httpOnly: true, secure: false });
      res.json({ success: true });
    } else {
      const data = await response.json();
      res.status(401).json({ errors: { login: data.message || 'Credenciales inválidas' } });
    }
  } catch (error) {
    res.status(500).json({ errors: { login: 'Error de conexión' } });
  }
});

app.post('/b2g/logout', (req, res) => {
  res.clearCookie('jwt');
  res.json({ success: true });
});

app.get('/b2g/api/user', async (req, res) => {
  const token = req.cookies.jwt;
  if (!token) {
    return res.status(401).json({ error: 'No autenticado' });
  }

  try {
    const response = await fetch(`${BACKEND_URL}/users/me`, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const data = await response.json();
      res.json(data);
    } else {
      res.status(401).json({ error: 'Token inválido' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error de conexión' });
  }
});

app.get('/b2g/api/captures', async (req, res) => {
  const token = req.cookies.jwt;
  if (!token) {
    return res.status(401).json({ error: 'No autenticado' });
  }

  try {
    const response = await fetch(`${BACKEND_URL}/captures`, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const data = await response.json();
      res.json(data);
    } else {
      res.status(401).json({ error: 'No autorizado' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error de conexión' });
  }
});

app.listen(PORT, () => {
  console.log(`B2G running on port ${PORT}`);
});
