<template>
  <div class="min-h-screen bg-gray-100">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-xl font-bold text-gray-900">AltruPets Admin</h1>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600">{{ user?.username }}</span>
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
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Panel de Administración</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <!-- Users Card -->
          <Link
            href="/admin/users"
            class="block p-6 bg-white rounded-lg shadow hover:shadow-lg transition-shadow"
          >
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Usuarios</h3>
            <p class="text-gray-600">Gestionar usuarios del sistema</p>
            <div class="mt-4 text-blue-600">Ver usuarios →</div>
          </Link>
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

const logout = async () => {
  await fetch('/logout', { method: 'POST', credentials: 'include' })
  window.location.href = '/login'
}
</script>
