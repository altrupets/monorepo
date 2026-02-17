import { UserRole } from './user-role.enum';

/**
 * Constantes de permisos RBAC para el sistema
 * Define qué roles pueden acceder a qué recursos
 */

// Roles que pueden ver y gestionar usuarios (Panel Admin - AltruPets Staff)
export const USER_ADMIN_ROLES = [
  UserRole.SUPER_USER,
  UserRole.USER_ADMIN,
  UserRole.LEGAL_REPRESENTATIVE,
];

// Roles que pueden ver solicitudes de captura (Panel B2G - Government)
export const CAPTURE_VIEWER_ROLES = [
  UserRole.SUPER_USER,
  UserRole.GOVERNMENT_ADMIN,
];

// SUPER_USER tiene acceso a todo
export const SUPER_USER_ROLES = [UserRole.SUPER_USER];
