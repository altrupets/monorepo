<template>
  <div class="dashboard-layout">
    <nav class="nav">
      <div class="nav-brand">
        <div class="brand-stub">🐾</div>
        <span>Portal de Gobierno</span>
      </div>
      <div class="nav-links">
        <a href="/b2g" class="active">Vista General</a>
        <a href="/b2g/abuse-reports">Denuncias</a>
        <a href="/b2g/subsidies">Subsidios</a>
      </div>
      <div class="nav-user-sec">
        <span class="nav-user">{{ user?.firstName }}</span>
        <button @click="handleLogout" class="logout-btn">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="18"
            height="18"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
          </svg>
        </button>
      </div>
    </nav>

    <main class="main-content">
      <header class="page-header">
        <div>
          <h1>Dashboard Municipal</h1>
          <p class="subtitle">
            Gestión operativa para
            {{ user?.organization?.name || "su municipalidad" }}
          </p>
        </div>
        <div class="header-actions">
          <button class="btn-primary" @click="refreshData">
            Actualizar datos
          </button>
        </div>
      </header>

      <div class="kpi-grid">
        <div class="kpi-card glass">
          <div class="kpi-icon abuse">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path
                d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"
              />
              <line x1="12" y1="9" x2="12" y2="13" />
              <line x1="12" y1="17" x2="12.01" y2="17" />
            </svg>
          </div>
          <div class="kpi-info">
            <span class="label">Reportes de Abuso</span>
            <h2 class="value">{{ stats.abuseReportsCount }}</h2>
            <span class="trend neutral">Pendientes de revisión</span>
          </div>
        </div>

        <div class="kpi-card glass">
          <div class="kpi-icon subsidy">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path
                d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"
              />
            </svg>
          </div>
          <div class="kpi-info">
            <span class="label">Subsidios Activos</span>
            <h2 class="value">{{ stats.activeSubsidiesCount }}</h2>
            <span class="trend positive">En proceso de pago</span>
          </div>
        </div>

        <div class="kpi-card glass">
          <div class="kpi-icon animals">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="M20 9v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V9" />
              <path d="M9 22V12h6v10" />
              <path d="M22 10V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v4" />
              <path d="M14 4h-4" />
            </svg>
          </div>
          <div class="kpi-info">
            <span class="label">Animales en Jurisdicción</span>
            <h2 class="value">{{ stats.animalsInJurisdictionCount }}</h2>
            <span class="trend positive">Registrados este mes</span>
          </div>
        </div>
      </div>

      <div class="data-section grid-2">
        <section class="card glass">
          <div class="card-header">
            <h3>Denuncias Recientes</h3>
            <a href="/b2g/abuse-reports" class="link">Ver todas</a>
          </div>
          <div class="recent-list">
            <div
              v-for="report in recentReports"
              :key="report.id"
              class="list-item"
            >
              <span class="item-id">#{{ report.trackingCode }}</span>
              <span class="item-type">{{ report.type }}</span>
              <span :class="['item-status', report.status.toLowerCase()]">{{
                report.status
              }}</span>
            </div>
            <p v-if="recentReports.length === 0" class="empty-msg">
              No hay denuncias pendientes.
            </p>
          </div>
        </section>

        <section class="card glass">
          <div class="card-header">
            <h3>Próximos Subsidios a Expirar</h3>
            <a href="/b2g/subsidies" class="link">Gestionar</a>
          </div>
          <div class="recent-list">
            <div
              v-for="subsidy in expiringSubsidies"
              :key="subsidy.id"
              class="list-item"
            >
              <span class="item-user">{{ subsidy.requester?.firstName }}</span>
              <span class="item-amount"
                >₡{{ subsidy.amountRequested.toLocaleString() }}</span
              >
              <span class="item-time">{{ formatTime(subsidy.expiresAt) }}</span>
            </div>
            <p v-if="expiringSubsidies.length === 0" class="empty-msg">
              No hay subsidios próximos a vencer.
            </p>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";

const user = ref(null);
const stats = ref({
  abuseReportsCount: 0,
  activeSubsidiesCount: 0,
  animalsInJurisdictionCount: 0,
});
const recentReports = ref([]);
const expiringSubsidies = ref([]);

const fetchDashboardData = async () => {
  try {
    // These will be proxies to our GraphQL backend
    const [userRes, statsRes] = await Promise.all([
      fetch("/b2g/api/user", { credentials: "include" }),
      fetch("/b2g/api/dashboard-stats", { credentials: "include" }),
    ]);

    if (userRes.ok) user.value = await userRes.json();
    else window.location.href = "/b2g/login";

    if (statsRes.ok) {
      const data = await statsRes.json();
      stats.value = data.stats;
      recentReports.value = data.recentReports;
      expiringSubsidies.value = data.expiringSubsidies;
    }
  } catch (e) {
    console.error("Failed to fetch dashboard data", e);
  }
};

const handleLogout = async () => {
  await fetch("/b2g/logout", { method: "POST" });
  window.location.href = "/b2g/login";
};

const refreshData = () => fetchDashboardData();

const formatTime = (dateStr) => {
  if (!dateStr) return "";
  const date = new Date(dateStr);
  return date.toLocaleDateString();
};

onMounted(fetchDashboardData);
</script>

<style scoped>
.dashboard-layout {
  min-height: 100vh;
  background: #f8fafc;
  color: #1e293b;
}

.nav {
  background: #0c4a6e;
  padding: 0.75rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.nav-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 700;
}

.logo {
  height: 32px;
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-links a {
  color: #bae6fd;
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
  transition: color 0.2s;
}

.nav-links a:hover,
.nav-links a.active {
  color: white;
}

.nav-user-sec {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.nav-user {
  font-size: 0.9rem;
  color: #e0f2fe;
}

.logout-btn {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  border-radius: 6px;
  padding: 0.5rem;
  color: white;
  cursor: pointer;
  display: flex;
  transition: background 0.2s;
}

.logout-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.main-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 2.5rem;
}

h1 {
  font-size: 1.875rem;
  color: #0f172a;
  margin-bottom: 0.25rem;
}
.subtitle {
  color: #64748b;
  font-size: 1rem;
}

.btn-primary {
  background: #0284c7;
  color: white;
  border: none;
  padding: 0.625rem 1.25rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-primary:hover {
  background: #0369a1;
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.card,
.kpi-card {
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}

.glass {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
}

.kpi-card {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  background: white;
}
.kpi-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.kpi-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.kpi-icon.abuse {
  background: #fee2e2;
  color: #ef4444;
}
.kpi-icon.subsidy {
  background: #dcfce7;
  color: #22c55e;
}
.kpi-icon.animals {
  background: #e0f2fe;
  color: #0ea5e9;
}

.kpi-info .label {
  font-size: 0.875rem;
  color: #64748b;
  font-weight: 500;
}
.kpi-info .value {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0.125rem 0;
}
.kpi-info .trend {
  font-size: 0.75rem;
  font-weight: 600;
}
.trend.neutral {
  color: #94a3b8;
}
.trend.positive {
  color: #10b981;
}

.grid-2 {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 1.5rem;
}

.card {
  background: white;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}
.card-header h3 {
  font-size: 1.125rem;
  font-weight: 600;
}
.link {
  font-size: 0.875rem;
  color: #0284c7;
  text-decoration: none;
  font-weight: 500;
}

.recent-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.list-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  background: #f8fafc;
  border-radius: 8px;
  font-size: 0.875rem;
}

.item-id {
  font-family: monospace;
  font-weight: 600;
  color: #64748b;
}
.item-status {
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
}
.item-status.submitted {
  background: #dcfce7;
  color: #166534;
}
.item-status.under_review {
  background: #fef9c3;
  color: #854d0e;
}

.item-amount {
  font-weight: 700;
  color: #0c4a6e;
}
.item-time {
  color: #94a3b8;
}

.empty-msg {
  text-align: center;
  color: #94a3b8;
  padding: 2rem 0;
  font-size: 0.9rem;
}
</style>
