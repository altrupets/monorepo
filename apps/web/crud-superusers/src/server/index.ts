import express from 'express'
import cookieParser from 'cookie-parser'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

const app = express()
const PORT = process.env.PORT || 3002
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend-service:3001'

app.use(cookieParser())
app.use(express.json())
app.use(express.static(resolve(__dirname, '../public')))

function renderPage(component: string, props: Record<string, any> = {}, title: string = 'AltruPets Admin'): string {
  const pageData = JSON.stringify({ component, props, url: '/admin', version: '1' })

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
    body { font-family: system-ui, -apple-system, sans-serif; background: #f5f5f5; min-height: 100vh; }
    .container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
    .card { background: white; border-radius: 8px; padding: 2rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .form-group { margin-bottom: 1rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    input { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem; }
    button { background: #3b82f6; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; }
    button:hover { background: #2563eb; }
    .error { color: #dc2626; margin-top: 0.5rem; }
    .nav { background: #1e293b; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    .nav a { color: white; text-decoration: none; margin-right: 1.5rem; }
    .nav a:hover { text-decoration: underline; }
    .nav-user { color: #94a3b8; }
    h1 { margin-bottom: 1.5rem; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #e5e7eb; }
    th { background: #f9fafb; font-weight: 600; }
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
              <h1 style="text-align: center; margin-bottom: 1.5rem;">AltruPets Admin</h1>
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
            const res = await fetch('/admin/login', {
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
                <a href="/admin">Dashboard</a>
                <a href="/admin/users">Usuarios</a>
              </div>
              <div>
                <span class="nav-user">{{ $page.props.user?.firstName }}</span>
                <form action="/admin/logout" method="POST" style="display: inline; margin-left: 1rem;">
                  <button style="background: transparent; padding: 0; color: #f87171;">Cerrar sesión</button>
                </form>
              </div>
            </nav>
            <div class="container">
              <div class="card">
                <h1>Bienvenido, {{ $page.props.user?.firstName }}</h1>
                <p style="margin-top: 1rem; color: #64748b;">Panel de administración de AltruPets</p>
              </div>
            </div>
          </div>
        \`
      },
      'Users/Index': {
        template: \`
          <div>
            <nav class="nav">
              <div>
                <a href="/admin">Dashboard</a>
                <a href="/admin/users">Usuarios</a>
              </div>
              <div>
                <span class="nav-user">{{ $page.props.user?.firstName }}</span>
                <form action="/admin/logout" method="POST" style="display: inline; margin-left: 1rem;">
                  <button style="background: transparent; padding: 0; color: #f87171;">Cerrar sesión</button>
                </form>
              </div>
            </nav>
            <div class="container">
              <div class="card">
                <h1>Gestión de Usuarios</h1>
                <table>
                  <thead><tr><th>ID</th><th>Usuario</th><th>Nombre</th><th>Roles</th></tr></thead>
                  <tbody>
                    <tr v-if="$page.props.users" v-for="u in $page.props.users" :key="u.id">
                      <td>{{ u.id }}</td><td>{{ u.username }}</td><td>{{ u.firstName }} {{ u.lastName }}</td><td>{{ u.roles?.join(', ') }}</td>
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

app.get('/admin', async (req, res) => {
  const user = await fetchUser(req)
  if (!user) return res.redirect('/admin/login')
  if (!hasRequiredRole(user)) {
    res.clearCookie('jwt')
    return res.send(renderPage('Auth/Login', { errors: { login: 'No tienes permisos' } }, 'Login'))
  }
  res.send(renderPage('Dashboard', { user }, 'Dashboard'))
})

app.get('/admin/users', async (req, res) => {
  const user = await fetchUser(req)
  if (!user) return res.redirect('/admin/login')
  if (!hasRequiredRole(user)) {
    res.clearCookie('jwt')
    return res.redirect('/admin/login')
  }
  const users = await fetchUsers(req)
  res.send(renderPage('Users/Index', { user, users }, 'Usuarios'))
})

app.get('/admin/login', async (req, res) => {
  const user = await fetchUser(req)
  if (user && hasRequiredRole(user)) return res.redirect('/admin')
  if (user) res.clearCookie('jwt')
  res.send(renderPage('Auth/Login', {}, 'Login'))
})

app.post('/admin/login', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body),
    })

    const setCookie = response.headers.get('set-cookie')
    if (setCookie) res.setHeader('Set-Cookie', setCookie)

    if (response.ok) return res.redirect('/admin')

    const data = await response.json()
    res.send(renderPage('Auth/Login', { errors: { login: data.message || 'Error de autenticación' } }, 'Login'))
  } catch {
    res.send(renderPage('Auth/Login', { errors: { login: 'Error de conexión' } }, 'Login'))
  }
})

app.post('/admin/logout', async (req, res) => {
  await fetch(`${BACKEND_URL}/logout`, {
    method: 'POST',
    headers: { Cookie: req.headers.cookie || '' },
  })
  res.clearCookie('jwt')
  res.redirect('/admin/login')
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

async function fetchUsers(req: express.Request): Promise<any[]> {
  if (!req.headers.cookie) return []
  try {
    const response = await fetch(`${BACKEND_URL}/graphql`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Cookie: req.headers.cookie },
      body: JSON.stringify({ query: `{ users { id username firstName lastName roles } }` }),
    })
    const data = await response.json()
    return data.data?.users || []
  } catch { return [] }
}

function hasRequiredRole(user: any): boolean {
  return user?.roles?.some((role: string) => ['SUPER_USER'].includes(role))
}

app.listen(PORT, () => console.log(`CRUD Superusers running on port ${PORT}`))
