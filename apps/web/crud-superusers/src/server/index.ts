import express from 'express'
import cookieParser from 'cookie-parser'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { createInertiaApp } from './inertia.js'

const __dirname = dirname(fileURLToPath(import.meta.url))

const app = express()
const PORT = process.env.PORT || 3002
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend-service:3001'
const IS_DEV = process.env.NODE_ENV !== 'production'

app.use(cookieParser())
app.use(express.json())

const inertia = createInertiaApp({
  resolvePage: (name) => {
    const pages = import.meta.glob('../Pages/**/*.vue', { eager: true })
    const page = pages[`../Pages/${name}.vue`]
    if (!page) throw new Error(`Page not found: ${name}`)
    return page
  },
  version: IS_DEV ? Date.now().toString() : '1',
})

app.use(inertia.middleware)

app.use(express.static(resolve(__dirname, '../../dist')))

app.get('/admin', async (req, res) => {
  const user = await fetchUser(req)
  if (!user) return res.redirect('/admin/login')
  if (!hasRequiredRole(user)) {
    res.clearCookie('jwt')
    return res.inertia.render('Auth/Login', { 
      title: 'Iniciar Sesión', 
      errors: { login: 'No tienes permisos para acceder a esta aplicación' }
    })
  }
  return res.inertia.render('Dashboard', { user, title: 'Admin Dashboard' })
})

app.get('/admin/users', async (req, res) => {
  const user = await fetchUser(req)
  if (!user) return res.redirect('/admin/login')
  if (!hasRequiredRole(user)) {
    res.clearCookie('jwt')
    return res.redirect('/admin/login')
  }
  return res.inertia.render('Users/Index', { user, title: 'Gestión de Usuarios' })
})

app.get('/admin/login', async (req, res) => {
  const user = await fetchUser(req)
  if (user && hasRequiredRole(user)) return res.redirect('/admin')
  if (user) {
    res.clearCookie('jwt')
  }
  return res.inertia.render('Auth/Login', { title: 'Iniciar Sesión', errors: {} })
})

app.post('/admin/login', async (req, res) => {
  try {
    const response = await fetch(`${BACKEND_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body),
      credentials: 'include',
    })
    
    const setCookie = response.headers.get('set-cookie')
    if (setCookie) {
      res.setHeader('Set-Cookie', setCookie)
    }
    
    if (response.redirected || response.ok) {
      return res.redirect('/admin')
    }
    
    const data = await response.json()
    return res.inertia.render('Auth/Login', { 
      title: 'Iniciar Sesión', 
      errors: { login: data.message || 'Error de autenticación' }
    })
  } catch (error) {
    return res.inertia.render('Auth/Login', { 
      title: 'Iniciar Sesión', 
      errors: { login: 'Error de conexión' }
    })
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
    if (setCookie) {
      res.setHeader('Set-Cookie', setCookie)
    }
    
    const data = await response.json()
    res.json(data)
  } catch (error) {
    res.status(500).json({ errors: [{ message: 'Backend connection error' }] })
  }
})

async function fetchUser(req: express.Request): Promise<any> {
  const cookie = req.headers.cookie
  if (!cookie) return null
  
  try {
    const response = await fetch(`${BACKEND_URL}/graphql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Cookie: cookie,
      },
      body: JSON.stringify({
        query: `{ currentUser { id username firstName lastName roles } }`
      }),
    })
    const data = await response.json()
    return data.data?.currentUser || null
  } catch {
    return null
  }
}

function hasRequiredRole(user: any): boolean {
  const allowedRoles = ['SUPER_USER', 'USER_ADMIN']
  return user?.roles?.some((role: string) => allowedRoles.includes(role))
}

app.listen(PORT, () => {
  console.log(`CRUD Superusers running on port ${PORT}`)
})
