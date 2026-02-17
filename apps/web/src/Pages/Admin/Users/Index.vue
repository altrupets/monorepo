<template>
  <div class="min-h-screen bg-gray-100">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-xl font-bold text-gray-900">AltruPets Admin</h1>
          </div>
          <div class="flex items-center space-x-4">
            <Link href="/admin" class="text-gray-600 hover:text-gray-900">
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
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Gestión de Usuarios</h2>
        
        <!-- Loading State -->
        <div v-if="loading" class="text-center py-8">
          <div class="text-gray-600">Cargando usuarios...</div>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          Error al cargar usuarios: {{ error }}
        </div>

        <!-- Users Table -->
        <div v-else class="bg-white shadow overflow-hidden sm:rounded-lg">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Usuario
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Roles
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Creado
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in users" :key="user.id">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div>
                      <div class="text-sm font-medium text-gray-900">
                        {{ user.firstName }} {{ user.lastName }}
                      </div>
                      <div class="text-sm text-gray-500">{{ user.username }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    v-for="role in user.roles"
                    :key="role"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 mr-2"
                  >
                    {{ role }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(user.createdAt) }}
                </td>
              </tr>
            </tbody>
          </table>
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

const users = ref([])
const loading = ref(true)
const error = ref(null)

// Fetch users using GraphQL via fetch
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
          query GetUsers {
            users {
              id
              username
              firstName
              lastName
              roles
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
      users.value = data.data.users
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
