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
        <h1>Bienvenido, {{ user?.firstName }}</h1>
        <p class="subtitle">Portal de Gobierno - AltruPets</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const user = ref(null);

const fetchUser = async () => {
  try {
    const res = await fetch('/b2g/api/user', {
      credentials: 'include'
    });
    if (res.ok) {
      const data = await res.json();
      user.value = data;
    } else {
      window.location.href = '/b2g/login';
    }
  } catch (e) {
    window.location.href = '/b2g/login';
  }
};

const handleLogout = async () => {
  await fetch('/b2g/logout', { method: 'POST' });
  window.location.href = '/b2g/login';
};

onMounted(fetchUser);
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
  margin-bottom: 1rem;
  color: #0c4a6e;
}

.subtitle {
  color: #64748b;
  margin-top: 0.5rem;
}
</style>
