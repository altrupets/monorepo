import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  root: resolve(__dirname, 'src'),
  publicDir: false,
  build: {
    outDir: resolve(__dirname, 'dist'),
    emptyOutDir: true,
    rollupOptions: {
      input: resolve(__dirname, 'src/app.ts'),
      output: {
        entryFileNames: 'js/app.js',
        chunkFileNames: 'js/[name]-[hash].js',
        assetFileNames: 'css/app.css',
      },
    },
  },
  server: {
    port: 5174,
    proxy: {
      '/graphql': { target: 'http://localhost:3001', changeOrigin: true },
      '/admin': { target: 'http://localhost:3002', changeOrigin: true },
      '/login': { target: 'http://localhost:3002', changeOrigin: true },
      '/logout': { target: 'http://localhost:3002', changeOrigin: true },
    },
  },
  resolve: {
    alias: {
      '@shared': resolve(__dirname, '../shared/src'),
    },
  },
})
