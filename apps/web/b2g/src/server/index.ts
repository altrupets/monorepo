import express from 'express'
import cookieParser from 'cookie-parser'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

const app = express()
const PORT = process.env.PORT || 3003
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend-service:3001'

app.use(cookieParser())
app.use(express.json())
app.use(express.static(resolve(__dirname, '../public')))

function renderPage(component: string, props: Record<string, any> = {}, title: string = 'AltruPets B2G'): string {
  const pageData = JSON.stringify({ component, props, url: '/b2g', version: '1' })

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <script src="https://unpkg.com/vue@3.4.38/dist/vue.global.prod.js"></script>
  <script src="https://unpkg.com/@inertiajs/inertia@0.11.1/dist/index.umd.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: system-ui, -apple-system, sans-serif; background: #f0f9ff; min-height: 100vh; }
    .container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
    .card { background: white; border-radius: 8px; padding: 2rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .form-group { margin-bottom: 1rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    input, select, textarea { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem; }
    button { background: #0369a1; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; }
    button:hover { background: #075985; }
    .error { color: #dc2626; margin-top: 0.5rem; }
    .nav { background: #0c4a6e; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    .nav a { color: white; text-decoration: none; margin-right: 1.5rem; }
    .nav a:hover { text-decoration: underline; }
    .nav-user { color: #bae6fd; }
    h1 { margin-bottom: 1.5rem; color: #0c4a6e; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #e0f2fe; }
    th { background: #f0f9ff; font-weight: 600; color: #0c4a6e; }
    .status { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.875rem; }
    .status-pending { background: #fef3c7; color: #92400e; }
    .status-approved { background: #d1fae5; color: #065f46; }
    .status-rejected { background: #fee2e2; color: #991b1b; }
  </style>
</head>
<body>
  <div id="app" data-page='${pageData.replace(/'/g, "&#039;")}'></div>
  <script>
    const { createApp, h } = Vue;
    const { createInertiaApp } = Inertia;

    const pages = {
      'Auth/Login': {
        template: \`
          <div class="container" style="display: flex; justify-content: center; align-items: center; min-height: 100vh;">
            <div class="card" style="width: 400px;">
              <h1 style="text-align: center; margin-bottom: 1.5rem;">AltruPets B2G</h1>
              <p style="text-align: center; color: #64748b; margin-bottom: 1.5rem;">Portal de Gobierno</p>
              <form @submit.prevent="submit">
                <div class="form-group">
                  <label>Usuario</label>
                  <input v-model="form.username" type="text" required />
                </div>
                <div class="form-group">
                  <label>Contraseña</label>
                  <input v-model="form.password" type="password" required />
                </div>
                <p v-if="$page.props.errors?.login" class="error">{{ $page.props.errors.login }}</p>
                <button type="submit" style="width: 100%; margin-top: 1rem;">Iniciar Sesión</button>
              </form>
            </div>
          </div>
        \`,
        data() { return { form: { username: '', password: '' } } },
        methods: {
          async submit() {
            const res = await fetch('/b2g/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(this.form)
            });
            if (res.redirected) window.location = res.url;
            else { const data = await res.json(); this.$page.props.errors = data.errors || { login: 'Error' }; }
          }
        }
      },
      'Dashboard': {
        template: \`
          <div>
            <nav class="nav">
              <div>
                <a href="/b2g">Dashboard</a>
                <a href="/b2g/captures">Solicitudes</a>
              </div>
              <div>
                <span class="nav-user">{{ $page.props.user?.firstName }}</span>
                <form action="/b2g/logout" method="POST" style="display: inline; margin-left: 1rem;">
                  <button style="background: transparent; padding: 0; color: #7dd3fc;">Cerrar sesión</button>
                </form>
              </div>
            </nav>
            <div class="container">
              <div class="card">
                <h1>Bienvenido, {{ $page.props.user?.firstName }}</h1>
                <p style="margin-top: 1rem; color: #64748b;">Portal de Gobierno - AltruPets</p>
              </div>
            </div>
          </div>
        \`
      },
      'Captures/Index': {
        template: \`
          <div>
            <nav class="nav">
              <div>
                <a href="/b2g">Dashboard</a>
                <a href="/b2g/captures">Solicitudes</a>
              </div>
              <div>
                <span class="nav-user">{{ $page.props.user?.firstName }}</span>
                <form action="/b2g/logout" method="POST" style="display: inline; margin-left: 1rem;">
                  <button style="background: transparent; padding: 0; color: #7dd3fc;">Cerrar sesión</button>
                </form>
              </div>
            </nav>
            <div class="container">
              <div class="card">
                <h1>Solicitudes de Captura</h1>
                <table>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Dirección</th>
                      <th>Fecha</th>
                      <th>Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="$page.props.captures" v-for="c in $page.props.captures" :key="c.id">
                      <td>{{ c.id }}</td>
                      <td>{{ c.address }}</td>
                      <td>{{ c.date }}</td>
                      <td><span :class="'status status-' + c.status.toLowerCase()">{{ c.status }}</span></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        \`
      }
    };

    createInertiaApp({
      resolve: name => pages[name] || { template: '<div>Page not found</div>' },
      setup({ el, App, props, plugin }) {
        createApp({ render: () => h(App, props) }).use(plugin).mount(el);
      }
    });
  </script>
</body>
</html>`
}

app.get('/b2g', async (req, res) => {
  const user = await fetchUser(req)
  if (!user) return res.redirect('/b2g/login')
  if (!hasRequiredRole(user)) {
    res.clearCookie('jwt')
    return res.send(renderPage('Auth/Login', { errors: { login: 'No tienes permisos' } }, 'Login'))
  }
  res.send(renderPage('Dashboard', { user }, 'Dashboard'))
})

app.get('/b2g/captures', async (req, res) => {
  const user = await fetchUser(req)
  if (!user) return res.redirect('/b2g/login')
  if (!hasRequiredRole(user)) {
    res.clearCookie('jwt')
    return res.redirect('/b2g/login')
  }
  const captures = await fetchCaptures(req)
  res.send(renderPage('Captures/Index', { user, captures }, 'Solicitudes'))
})

app.get('/b2g/login', async (req, res) => {
  const user = await fetchUser(req)
  if (user && hasRequiredRole(user)) return res.redirect('/b2g')
  if (user) res.clearCookie('jwt')
  res.send(renderPage('Auth/Login', {}, 'Login'))
})

app.post('/b2g/login', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body),
    })

    const setCookie = response.headers.get('set-cookie')
    if (setCookie) res.setHeader('Set-Cookie', setCookie)

    if (response.ok) return res.redirect('/b2g')

    const data = await response.json()
    res.send(renderPage('Auth/Login', { errors: { login: data.message || 'Error de autenticación' } }, 'Login'))
  } catch {
    res.send(renderPage('Auth/Login', { errors: { login: 'Error de conexión' } }, 'Login'))
  }
})

app.post('/b2g/logout', async (req, res) => {
  await fetch(`${BACKEND_URL}/logout`, {
    method: 'POST',
    headers: { Cookie: req.headers.cookie || '' },
  })
  res.clearCookie('jwt')
  res.redirect('/b2g/login')
})

app.use('/graphql', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/graphql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Cookie: req.headers.cookie || '',
      },
      body: JSON.stringify(req.body),
    })

    const setCookie = response.headers.get('set-cookie')
    if (setCookie) res.setHeader('Set-Cookie', setCookie)

    res.json(await response.json())
  } catch {
    res.status(500).json({ errors: [{ message: 'Backend connection error' }] })
  }
})

async function fetchUser(req: express.Request): Promise<any> {
  if (!req.headers.cookie) return null
  try {
    const response = await fetch(`${BACKEND_URL}/graphql`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Cookie: req.headers.cookie },
      body: JSON.stringify({ query: `{ currentUser { id username firstName lastName roles } }` }),
    })
    const data = await response.json()
    return data.data?.currentUser || null
  } catch { return null }
}

async function fetchCaptures(req: express.Request): Promise<any[]> {
  if (!req.headers.cookie) return []
  try {
    const response = await fetch(`${BACKEND_URL}/graphql`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Cookie: req.headers.cookie },
      body: JSON.stringify({ query: `{ captureRequests { id address date status } }` }),
    })
    const data = await response.json()
    return data.data?.captureRequests || []
  } catch { return [] }
}

function hasRequiredRole(user: any): boolean {
  return user?.roles?.some((role: string) => ['GOVERNMENT_ADMIN', 'SUPER_USER'].includes(role))
}

app.listen(PORT, () => console.log(`B2G app running on port ${PORT}`))
