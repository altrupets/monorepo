import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'
import fs from 'fs'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    {
      name: 'copy-fonts',
      writeBundle() {
        const fontsDir = resolve(__dirname, '../backend/public/dist/fonts')
        const srcFontsDir = resolve(__dirname, '../../style-dictionary/fonts')
        
        if (!fs.existsSync(fontsDir)) {
          fs.mkdirSync(fontsDir, { recursive: true })
        }
        
        const copyDir = (src: string, dest: string) => {
          if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest, { recursive: true })
          }
          const entries = fs.readdirSync(src, { withFileTypes: true })
          for (const entry of entries) {
            const srcPath = resolve(src, entry.name)
            const destPath = resolve(dest, entry.name)
            if (entry.isDirectory()) {
              copyDir(srcPath, destPath)
            } else {
              fs.copyFileSync(srcPath, destPath)
            }
          }
        }
        
        copyDir(srcFontsDir, fontsDir)
      }
    }
  ],
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
