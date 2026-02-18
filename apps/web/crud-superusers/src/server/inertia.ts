import { Request, Response, NextFunction } from 'express'

interface InertiaConfig {
  resolvePage: (name: string) => any
  version: string
  htmlTemplate?: string
}

interface InertiaPage {
  component: string
  props: Record<string, any>
  url: string
  version: string
}

export function createInertiaApp(config: InertiaConfig) {
  const { resolvePage, version, htmlTemplate } = config

  function renderPage(component: string, props: Record<string, any>, req: Request): string {
    const page: InertiaPage = {
      component,
      props,
      url: req.originalUrl,
      version,
    }

    const pageJson = JSON.stringify(page)
    
    // Use provided template or default
    const baseHtml = htmlTemplate || `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AltruPets</title>
</head>
<body>
  <div id="app"></div>
</body>
</html>`
    
    // Inject page data into the HTML
    return baseHtml.replace(
      '<div id="app"></div>',
      `<div id="app" data-page="${escapeHtml(pageJson)}"></div>`
    )
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
    middleware: (req: Request, res: Response, next: NextFunction) => {
      res.inertia = {
        render: (component: string, props: Record<string, any> = {}) => {
          if (req.headers['x-inertia']) {
            res.json({
              component,
              props,
              url: req.originalUrl,
              version,
            })
            return
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
      render: (component: string, props?: Record<string, any>) => void
      redirect: (url: string) => void
    }
  }
}
