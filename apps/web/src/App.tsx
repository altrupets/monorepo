import React, { useState, useEffect } from 'react';
import { getUsers } from './services/userService';
import { User } from './types/user';
import { UserList } from './components/UserList';
import { UserDetail } from './components/UserDetail';
import './App.css';

function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getUsers();
      setUsers(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error al cargar usuarios');
      console.error('Error loading users:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app">
      <header style={{ padding: '20px', borderBottom: '1px solid #333' }}>
        <h1>AltruPets - User Management CRUD</h1>
        <p>Verifica que los datos actualizados desde la app Flutter se persisten correctamente</p>
        <button onClick={loadUsers} disabled={loading}>
          {loading ? 'Cargando...' : 'Refrescar'}
        </button>
      </header>

      <main style={{ padding: '20px' }}>
        {error && (
          <div
            style={{
              padding: '12px',
              backgroundColor: '#ff4444',
              color: 'white',
              borderRadius: '4px',
              marginBottom: '20px',
            }}
          >
            Error: {error}
          </div>
        )}

        {loading ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            Cargando usuarios...
          </div>
        ) : users.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            No hay usuarios disponibles
          </div>
        ) : (
          <UserList
            users={users}
            onUserClick={(user) => setSelectedUser(user)}
          />
        )}
      </main>

      {selectedUser && (
        <UserDetail
          user={selectedUser}
          onClose={() => setSelectedUser(null)}
        />
      )}
    </div>
  );
}

export default App;
