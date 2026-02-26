import { createApp } from 'vue';
import { createRouter, createWebHistory } from 'vue-router';
import Login from './pages/Auth/Login.vue';
import Dashboard from './pages/Dashboard.vue';
import UsersIndex from './pages/Users/Index.vue';

const routes = [
  { path: '/admin/login', name: 'login', component: Login },
  { path: '/admin', name: 'dashboard', component: Dashboard },
  { path: '/admin/users', name: 'users', component: UsersIndex },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

const app = createApp({});
app.use(router);
app.mount('#app');
