<template>
  <div class="min-h-screen bg-gray-100">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-xl font-bold text-indigo-900">AltruPets B2G</h1>
          </div>
          <div class="flex items-center space-x-4">
            <Link href="/b2g" class="text-gray-600 hover:text-gray-900">
              ← Volver al Panel
            </Link>
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
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Solicitudes de Captura</h2>
        
        <!-- Loading State -->
        <div v-if="loading" class="text-center py-8">
          <div class="text-gray-600">Cargando solicitudes...</div>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          Error al cargar solicitudes: {{ error }}
        </div>

        <!-- Captures Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="capture in captures"
            :key="capture.id"
            class="bg-white rounded-lg shadow overflow-hidden"
          >
            <div class="p-6">
              <div class="flex items-center justify-between mb-4">
                <span
                  :class="{
                    'bg-yellow-100 text-yellow-800': capture.status === 'PENDING',
                    'bg-green-100 text-green-800': capture.status === 'COMPLETED',
                    'bg-blue-100 text-blue-800': capture.status === 'IN_PROGRESS'
                  }"
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                >
                  {{ capture.status }}
                </span>
                <span class="text-sm text-gray-500">
                  {{ formatDate(capture.createdAt) }}
                </span>
              </div>
              
              <h3 class="text-lg font-semibold text-gray-900 mb-2">
                {{ capture.animalType || 'Animal' }}
              </h3>
              
              <p class="text-gray-600 text-sm mb-4">
                {{ capture.description || 'Sin descripción' }}
              </p>
              
              <div class="flex items-center text-sm text-gray-500 mb-4">
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                {{ capture.latitude?.toFixed(4) }}, {{ capture.longitude?.toFixed(4) }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Link } from '@inertiajs/vue3'

const props = defineProps({
  title: String,
})

const captures = ref([])
const loading = ref(true)
const error = ref(null)

// Fetch captures using GraphQL via fetch
onMounted(async () => {
  try {
    const response = await fetch('/graphql', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify({
        query: `
          query GetCaptureRequests {
            getCaptureRequests {
              id
              latitude
              longitude
              description
              animalType
              status
              imageUrl
              createdAt
            }
          }
        `
      })
    })
    
    const data = await response.json()
    
    if (data.errors) {
      error.value = data.errors[0].message
    } else {
      captures.value = data.data.getCaptureRequests
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
})

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('es-ES')
}

const logout = () => {
  window.location.href = '/logout'
}
</script>
