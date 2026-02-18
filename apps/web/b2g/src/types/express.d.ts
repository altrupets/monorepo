import 'express'

declare module 'express' {
  interface Response {
    inertia: {
      render: (component: string, props?: Record<string, any>) => void
      redirect: (url: string) => void
    }
  }
}

interface ImportMeta {
  glob(pattern: string, options?: { eager?: boolean }): Record<string, any>
}
