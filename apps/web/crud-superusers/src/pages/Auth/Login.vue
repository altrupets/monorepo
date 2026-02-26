<template>
  <div class="container">
    <div class="card">
      <h1>AltruPets Admin</h1>
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label>Usuario</label>
          <input v-model="form.username" type="text" required />
        </div>
        <div class="form-group">
          <label>Contraseña</label>
          <input v-model="form.password" type="password" required />
        </div>
        <p v-if="error" class="error">{{ error }}</p>
        <button type="submit" :disabled="loading">
          {{ loading ? 'Iniciando...' : 'Iniciar Sesión' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const form = reactive({ username: '', password: '' });
const error = ref('');
const loading = ref(false);

const handleLogin = async () => {
  error.value = '';
  loading.value = true;

  try {
    const res = await fetch('/admin/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });

    if (res.ok || res.redirected) {
      window.location.href = '/admin';
    } else {
      const data = await res.json();
      error.value = data.errors?.login || 'Error de autenticación';
    }
  } catch (e) {
    error.value = 'Error de conexión';
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}

.card {
  width: 400px;
}

h1 {
  text-align: center;
  margin-bottom: 1.5rem;
}

.form-group {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

button {
  width: 100%;
  margin-top: 1rem;
  background: #3b82f6;
  color: white;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

button:hover:not(:disabled) {
  background: #2563eb;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  color: #dc2626;
  margin-top: 0.5rem;
}
</style>
