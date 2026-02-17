<template>
  <div class="min-h-screen bg-gray-100">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-xl font-bold text-indigo-900">AltruPets B2G</h1>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600">Gobierno Local</span>
            <button
              @click="logout"
              class="text-sm text-red-600 hover:text-red-800"
            >
              Cerrar Sesión
            </button>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Panel B2G - Gobierno Local</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Captures Card -->
          <Link
            href="/b2g/captures"
            class="block p-6 bg-white rounded-lg shadow hover:shadow-lg transition-shadow border-l-4 border-indigo-500"
          >
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Solicitudes de Captura</h3>
            <p class="text-gray-600">Ver y gestionar solicitudes de captura de animales</p>
            <div class="mt-4 text-indigo-600">Ver solicitudes →</div>
          </Link>

          <!-- Reports Card -->
          <div class="block p-6 bg-white rounded-lg shadow border-l-4 border-gray-300">
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Reportes</h3>
            <p class="text-gray-600">Generar reportes de actividad (próximamente)</p>
            <div class="mt-4 text-gray-400">No disponible</div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { Link } from '@inertiajs/vue3'

defineProps({
  user: Object,
  title: String,
})

const logout = () => {
  window.location.href = '/logout'
}
</script>
