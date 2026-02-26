<template>
  <div>
    <nav class="nav">
      <div>
        <a href="/admin">Dashboard</a>
        <a href="/admin/users">Usuarios</a>
      </div>
      <div>
        <span class="nav-user">{{ user?.firstName }}</span>
        <button @click="handleLogout" class="logout-btn">Cerrar sesión</button>
      </div>
    </nav>
    <div class="container">
      <div class="card">
        <h1>Gestión de Usuarios</h1>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Usuario</th>
              <th>Nombre</th>
              <th>Roles</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in users" :key="u.id">
              <td>{{ u.id }}</td>
              <td>{{ u.username }}</td>
              <td>{{ u.firstName }} {{ u.lastName }}</td>
              <td>{{ u.roles?.join(', ') }}</td>
              <td>
                <button class="action-btn">Editar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const user = ref(null);
const users = ref([]);

const fetchData = async () => {
  try {
    const [userRes, usersRes] = await Promise.all([
      fetch('/admin/api/user', { credentials: 'include' }),
      fetch('/admin/api/users', { credentials: 'include' })
    ]);

    if (!userRes.ok) {
      window.location.href = '/admin/login';
      return;
    }

    user.value = await userRes.json();

    if (usersRes.ok) {
      users.value = await usersRes.json();
    }
  } catch (e) {
    window.location.href = '/admin/login';
  }
};

const handleLogout = async () => {
  await fetch('/admin/logout', { method: 'POST' });
  window.location.href = '/admin/login';
};

onMounted(fetchData);
</script>

<style scoped>
.nav {
  background: #1e293b;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav a {
  color: white;
  text-decoration: none;
  margin-right: 1.5rem;
}

.nav a:hover {
  text-decoration: underline;
}

.nav-user {
  color: #94a3b8;
}

.logout-btn {
  background: transparent;
  padding: 0;
  color: #f87171;
  margin-left: 1rem;
  cursor: pointer;
  border: none;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.card {
  background: white;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

h1 {
  margin-bottom: 1.5rem;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}

th, td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
}

th {
  background: #f9fafb;
  font-weight: 600;
}

.action-btn {
  background: #3b82f6;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.action-btn:hover {
  background: #2563eb;
}
</style>
