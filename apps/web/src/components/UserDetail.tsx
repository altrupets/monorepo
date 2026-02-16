import React from 'react';
import { User } from '../types/user';

interface UserDetailProps {
  user: User;
  onClose: () => void;
}

export const UserDetail: React.FC<UserDetailProps> = ({ user, onClose }) => {
  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
      }}
      onClick={onClose}
    >
      <div
        style={{
          backgroundColor: '#1a1a1a',
          padding: '24px',
          borderRadius: '8px',
          maxWidth: '600px',
          width: '90%',
          maxHeight: '90vh',
          overflow: 'auto',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h2 style={{ margin: 0 }}>Detalle de Usuario</h2>
          <button onClick={onClose}>Cerrar</button>
        </div>

        <div style={{ display: 'grid', gap: '16px' }}>
          <div>
            <strong>ID:</strong> {user.id}
          </div>
          <div>
            <strong>Username:</strong> {user.username}
          </div>
          <div>
            <strong>Roles:</strong> {user.roles?.join(', ') || '-'}
          </div>
          <div>
            <strong>Nombre:</strong> {user.firstName || '-'}
          </div>
          <div>
            <strong>Apellido:</strong> {user.lastName || '-'}
          </div>
          <div>
            <strong>Teléfono:</strong> {user.phone || '-'}
          </div>
          <div>
            <strong>Cédula:</strong> {user.identification || '-'}
          </div>
          <div>
            <strong>País:</strong> {user.country || '-'}
          </div>
          <div>
            <strong>Provincia:</strong> {user.province || '-'}
          </div>
          <div>
            <strong>Cantón:</strong> {user.canton || '-'}
          </div>
          <div>
            <strong>Distrito:</strong> {user.district || '-'}
          </div>
          <div>
            <strong>Creado:</strong>{' '}
            {user.createdAt
              ? new Date(user.createdAt).toLocaleString('es-ES')
              : '-'}
          </div>
          <div>
            <strong>Última Actualización:</strong>{' '}
            {user.updatedAt
              ? new Date(user.updatedAt).toLocaleString('es-ES')
              : '-'}
          </div>
        </div>
      </div>
    </div>
  );
};
