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
        <h1>Bienvenido, {{ user?.firstName }}</h1>
        <p class="subtitle">Panel de administración de AltruPets</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const user = ref(null);

const fetchUser = async () => {
  try {
    const res = await fetch('/admin/api/user', {
      credentials: 'include'
    });
    if (res.ok) {
      const data = await res.json();
      user.value = data;
    } else {
      window.location.href = '/admin/login';
    }
  } catch (e) {
    window.location.href = '/admin/login';
  }
};

const handleLogout = async () => {
  await fetch('/admin/logout', { method: 'POST' });
  window.location.href = '/admin/login';
};

onMounted(fetchUser);
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
  margin-bottom: 1rem;
}

.subtitle {
  color: #64748b;
  margin-top: 0.5rem;
}
</style>
