<template>
  <div>
    <nav class="nav">
      <div>
        <a href="/b2g">Dashboard</a>
        <a href="/b2g/requests">Solicitudes</a>
      </div>
      <div>
        <span class="nav-user">{{ user?.firstName }}</span>
        <button @click="handleLogout" class="logout-btn">Cerrar sesión</button>
      </div>
    </nav>
    <div class="container">
      <div class="card">
        <h1>Solicitudes de Captura</h1>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Dirección</th>
              <th>Fecha</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in captures" :key="c.id">
              <td>{{ c.id }}</td>
              <td>{{ c.address }}</td>
              <td>{{ c.date }}</td>
              <td>
                <span :class="'status status-' + c.status.toLowerCase()">{{ c.status }}</span>
              </td>
              <td>
                <button class="action-btn" @click="viewCapture(c)">Ver</button>
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
const captures = ref([]);

const fetchData = async () => {
  try {
    const [userRes, capturesRes] = await Promise.all([
      fetch('/b2g/api/user', { credentials: 'include' }),
      fetch('/b2g/api/captures', { credentials: 'include' })
    ]);

    if (!userRes.ok) {
      window.location.href = '/b2g/login';
      return;
    }

    user.value = await userRes.json();

    if (capturesRes.ok) {
      captures.value = await capturesRes.json();
    }
  } catch (e) {
    window.location.href = '/b2g/login';
  }
};

const viewCapture = (capture) => {
  console.log('View capture:', capture);
};

const handleLogout = async () => {
  await fetch('/b2g/logout', { method: 'POST' });
  window.location.href = '/b2g/login';
};

onMounted(fetchData);
</script>

<style scoped>
.nav {
  background: #0c4a6e;
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
  color: #bae6fd;
}

.logout-btn {
  background: transparent;
  padding: 0;
  color: #7dd3fc;
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
  color: #0c4a6e;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}

th, td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #e0f2fe;
}

th {
  background: #f0f9ff;
  font-weight: 600;
  color: #0c4a6e;
}

.status {
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.875rem;
}

.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.status-approved {
  background: #d1fae5;
  color: #065f46;
}

.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

.action-btn {
  background: #0369a1;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.action-btn:hover {
  background: #075985;
}
</style>
