import { Request, Response } from 'express'

interface InertiaConfig {
  resolvePage: (name: string) => Promise<any>
  version: string
}

interface InertiaPage {
  component: string
  props: Record<string, any>
  url: string
  version: string
}

export function createInertiaApp(config: InertiaConfig) {
  const { resolvePage, version } = config

  function renderPage(component: string, props: Record<string, any>, req: Request): string {
    const page: InertiaPage = {
      component,
      props,
      url: req.originalUrl,
      version,
    }

    const pageJson = JSON.stringify(page)
    
    return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AltruPets - Admin</title>
  <link rel="stylesheet" href="/dist/css/app.css">
</head>
<body>
  <div id="app" data-page="${escapeHtml(pageJson)}"></div>
  <script type="module" src="/dist/js/app.js"></script>
</body>
</html>`
  }

  function escapeHtml(str: string): string {
    return str
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
  }

  return {
    middleware: (req: Request, res: Response, next: express.NextFunction) => {
      res.inertia = {
        render: async (component: string, props: Record<string, any> = {}) => {
          if (req.headers['x-inertia']) {
            return res.json({
              component,
              props,
              url: req.originalUrl,
              version,
            })
          }
          
          const html = renderPage(component, props, req)
          res.send(html)
        },
        redirect: (url: string) => {
          if (req.headers['x-inertia']) {
            res.setHeader('X-Inertia-Location', url)
            return res.status(409).send('')
          }
          res.redirect(url)
        },
      }
      next()
    },
  }
}

declare module 'express' {
  interface Response {
    inertia: {
      render: (component: string, props?: Record<string, any>) => Promise<void>
      redirect: (url: string) => void
    }
  }
}
