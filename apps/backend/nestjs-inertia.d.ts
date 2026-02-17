declare module 'nestjs-inertia' {
  import { RequestHandler } from 'express';
  
  export const inertiaMiddleware: RequestHandler;
  
  export interface InertiaResponse {
    render(component: string, props?: Record<string, any>): any;
  }
}

declare global {
  namespace Express {
    interface Response {
      inertia: {
        render(component: string, props?: Record<string, any>): any;
      };
    }
  }
}
