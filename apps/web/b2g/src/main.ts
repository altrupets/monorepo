import { createApp } from 'vue';
import { createRouter, createWebHistory } from 'vue-router';
import Login from './pages/Auth/Login.vue';
import Dashboard from './pages/Dashboard.vue';
import RequestsIndex from './pages/Requests/Index.vue';

const routes = [
  { path: '/b2g/login', name: 'login', component: Login },
  { path: '/b2g', name: 'dashboard', component: Dashboard },
  { path: '/b2g/requests', name: 'requests', component: RequestsIndex },
];

const router = createRouter({
  history: createWebHistory('/b2g'),
  routes,
});

const app = createApp({});
app.use(router);
app.mount('#app');
