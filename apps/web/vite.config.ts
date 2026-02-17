import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  build: {
    outDir: resolve(__dirname, '../backend/public'),
    emptyOutDir: true,
    rollupOptions: {
      output: {
        entryFileNames: 'dist/js/app.js',
        chunkFileNames: 'dist/js/[name]-[hash].js',
        assetFileNames: (assetInfo) => {
          if (assetInfo.name?.endsWith('.css')) {
            return 'dist/css/app.css'
          }
          return 'dist/assets/[name]-[hash][extname]'
        },
      },
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/graphql': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
      '/admin': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
      '/b2g': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
      '/login': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
      '/logout': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
})
