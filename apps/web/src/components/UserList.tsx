import React from 'react';
import { User } from '../types/user';

interface UserListProps {
  users: User[];
  onUserClick: (user: User) => void;
}

export const UserList: React.FC<UserListProps> = ({ users, onUserClick }) => {
  return (
    <div style={{ width: '100%', overflowX: 'auto' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '20px' }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #646cff' }}>
            <th style={{ padding: '12px', textAlign: 'left' }}>Username</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Nombre</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Apellido</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Teléfono</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Última Actualización</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Acciones</th>
          </tr>
        </thead>
        <tbody>
          {users.map((user) => (
            <tr
              key={user.id}
              style={{
                borderBottom: '1px solid #333',
                cursor: 'pointer',
              }}
              onClick={() => onUserClick(user)}
              onMouseEnter={(e) => {
                e.currentTarget.style.backgroundColor = '#333';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.backgroundColor = 'transparent';
              }}
            >
              <td style={{ padding: '12px' }}>{user.username}</td>
              <td style={{ padding: '12px' }}>{user.firstName || '-'}</td>
              <td style={{ padding: '12px' }}>{user.lastName || '-'}</td>
              <td style={{ padding: '12px' }}>{user.phone || '-'}</td>
              <td style={{ padding: '12px' }}>
                {user.updatedAt
                  ? new Date(user.updatedAt).toLocaleString('es-ES')
                  : '-'}
              </td>
              <td style={{ padding: '12px' }}>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onUserClick(user);
                  }}
                >
                  Ver Detalle
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
