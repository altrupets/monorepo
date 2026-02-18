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
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-900">Gestión de Usuarios</h2>
          <button
            @click="showCreateModal = true"
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            + Nuevo Usuario
          </button>
        </div>
        
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
                  Estado
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Creado
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in users" :key="user.id">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div>
                      <div class="text-sm font-medium text-gray-900">
                        {{ user.firstName || '-' }} {{ user.lastName || '' }}
                      </div>
                      <div class="text-sm text-gray-500">{{ user.username }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    v-for="role in user.roles"
                    :key="role"
                    :class="getRoleClass(role)"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium mr-1"
                  >
                    {{ formatRole(role) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="user.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  >
                    {{ user.isActive ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(user.createdAt) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                  <button
                    @click="openEditModal(user)"
                    class="text-indigo-600 hover:text-indigo-900 mr-3"
                  >
                    Editar
                  </button>
                  <button
                    v-if="!isSuperUser(user)"
                    @click="confirmDelete(user)"
                    class="text-red-600 hover:text-red-900"
                  >
                    Eliminar
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>

    <!-- Edit Modal -->
    <div v-if="showEditModal" class="fixed z-10 inset-0 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 transition-opacity" @click="showEditModal = false">
          <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
        </div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          <form @submit.prevent="saveUser">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <h3 class="text-lg font-medium text-gray-900 mb-4">
                {{ editingUser?.id ? 'Editar Usuario' : 'Nuevo Usuario' }}
              </h3>
              
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700">Usuario</label>
                  <input
                    v-model="editForm.username"
                    type="text"
                    :disabled="!!editingUser?.id"
                    class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    required
                  />
                </div>
                
                <div v-if="!editingUser?.id">
                  <label class="block text-sm font-medium text-gray-700">Contraseña</label>
                  <input
                    v-model="editForm.password"
                    type="password"
                    class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    :required="!editingUser?.id"
                  />
                </div>

                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700">Nombre</label>
                    <input
                      v-model="editForm.firstName"
                      type="text"
                      class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700">Apellido</label>
                    <input
                      v-model="editForm.lastName"
                      type="text"
                      class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    />
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Roles</label>
                  <div class="mt-2 space-y-2">
                    <label v-for="role in availableRoles" :key="role" class="flex items-center">
                      <input
                        type="checkbox"
                        :value="role"
                        v-model="editForm.roles"
                        class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                      />
                      <span class="ml-2 text-sm text-gray-700">{{ formatRole(role) }}</span>
                    </label>
                  </div>
                </div>

                <div>
                  <label class="flex items-center">
                    <input
                      type="checkbox"
                      v-model="editForm.isActive"
                      class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                    />
                    <span class="ml-2 text-sm text-gray-700">Usuario activo</span>
                  </label>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              <button
                type="submit"
                :disabled="saving"
                class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50"
              >
                {{ saving ? 'Guardando...' : 'Guardar' }}
              </button>
              <button
                type="button"
                @click="showEditModal = false"
                class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="fixed z-10 inset-0 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 transition-opacity" @click="showDeleteModal = false">
          <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
        </div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Confirmar Eliminación</h3>
            <p class="text-sm text-gray-500">
              ¿Está seguro que desea eliminar al usuario <strong>{{ deletingUser?.username }}</strong>?
              Esta acción no se puede deshacer.
            </p>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button
              @click="deleteUser"
              :disabled="deleting"
              class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50"
            >
              {{ deleting ? 'Eliminando...' : 'Eliminar' }}
            </button>
            <button
              type="button"
              @click="showDeleteModal = false"
              class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
            >
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { Link } from '@inertiajs/vue3'

const props = defineProps({
  title: String,
})

const users = ref([])
const loading = ref(true)
const error = ref(null)

const showEditModal = ref(false)
const showCreateModal = ref(false)
const showDeleteModal = ref(false)
const editingUser = ref(null)
const deletingUser = ref(null)
const saving = ref(false)
const deleting = ref(false)

const availableRoles = [
  'SUPER_USER',
  'GOVERNMENT_ADMIN',
  'USER_ADMIN',
  'RESCUER',
  'HELPER',
  'WATCHER',
]

const editForm = reactive({
  username: '',
  password: '',
  firstName: '',
  lastName: '',
  roles: ['WATCHER'],
  isActive: true,
})

onMounted(async () => {
  await fetchUsers()
})

const fetchUsers = async () => {
  loading.value = true
  try {
    const response = await fetch('/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
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
              isActive
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
}

const openEditModal = (user) => {
  editingUser.value = user
  editForm.username = user.username
  editForm.password = ''
  editForm.firstName = user.firstName || ''
  editForm.lastName = user.lastName || ''
  editForm.roles = [...user.roles]
  editForm.isActive = user.isActive ?? true
  showEditModal.value = true
}

const saveUser = async () => {
  saving.value = true
  try {
    const mutation = editingUser.value?.id
      ? `mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
          updateUser(id: $id, input: $input) {
            id
            username
            firstName
            lastName
            roles
            isActive
          }
        }`
      : `mutation CreateUser($input: CreateUserInput!) {
          createUser(input: $input) {
            id
            username
            firstName
            lastName
            roles
            isActive
          }
        }`

    const variables = editingUser.value?.id
      ? { id: editingUser.value.id, input: { firstName: editForm.firstName, lastName: editForm.lastName, roles: editForm.roles, isActive: editForm.isActive } }
      : { input: { username: editForm.username, password: editForm.password, firstName: editForm.firstName, lastName: editForm.lastName, roles: editForm.roles } }

    const response = await fetch('/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({ query: mutation, variables })
    })
    
    const data = await response.json()
    
    if (data.errors) {
      alert('Error: ' + data.errors[0].message)
    } else {
      showEditModal.value = false
      await fetchUsers()
    }
  } catch (err) {
    alert('Error: ' + err.message)
  } finally {
    saving.value = false
  }
}

const confirmDelete = (user) => {
  deletingUser.value = user
  showDeleteModal.value = true
}

const deleteUser = async () => {
  deleting.value = true
  try {
    const response = await fetch('/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({
        query: `mutation DeleteUser($id: ID!) {
          deleteUser(id: $id)
        }`,
        variables: { id: deletingUser.value.id }
      })
    })
    
    const data = await response.json()
    
    if (data.errors) {
      alert('Error: ' + data.errors[0].message)
    } else {
      showDeleteModal.value = false
      await fetchUsers()
    }
  } catch (err) {
    alert('Error: ' + err.message)
  } finally {
    deleting.value = false
  }
}

const isSuperUser = (user) => user.roles.includes('SUPER_USER')

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('es-ES')
}

const formatRole = (role) => {
  const roleNames = {
    'SUPER_USER': 'Super Admin',
    'GOVERNMENT_ADMIN': 'Gobierno (B2G)',
    'USER_ADMIN': 'Admin Usuarios',
    'RESCUER': 'Rescatista',
    'HELPER': 'Auxiliar',
    'WATCHER': 'Observador',
  }
  return roleNames[role] || role
}

const getRoleClass = (role) => {
  const classes = {
    'SUPER_USER': 'bg-purple-100 text-purple-800',
    'GOVERNMENT_ADMIN': 'bg-green-100 text-green-800',
    'USER_ADMIN': 'bg-blue-100 text-blue-800',
    'RESCUER': 'bg-orange-100 text-orange-800',
    'HELPER': 'bg-yellow-100 text-yellow-800',
    'WATCHER': 'bg-gray-100 text-gray-800',
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

const logout = async () => {
  await fetch('/logout', { method: 'POST', credentials: 'include' })
  window.location.href = '/login'
}

watch(showCreateModal, (val) => {
  if (val) {
    editingUser.value = null
    editForm.username = ''
    editForm.password = ''
    editForm.firstName = ''
    editForm.lastName = ''
    editForm.roles = ['WATCHER']
    editForm.isActive = true
    showEditModal.value = true
    showCreateModal.value = false
  }
})
</script>
