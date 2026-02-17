import { registerEnumType } from '@nestjs/graphql';

export enum UserRole {
  // Super Administrator
  SUPER_USER = 'SUPER_USER',

  // Administrative Roles (B2G)
  GOVERNMENT_ADMIN = 'GOVERNMENT_ADMIN',

  // Administrative Roles (AltruPets Staff)
  USER_ADMIN = 'USER_ADMIN',
  LEGAL_REPRESENTATIVE = 'LEGAL_REPRESENTATIVE',

  // Operational Roles
  WATCHER = 'WATCHER',           // Previously: CENTINELA
  HELPER = 'HELPER',             // Previously: AUXILIAR
  RESCUER = 'RESCUER',           // Previously: RESCATISTA
  ADOPTER = 'ADOPTER',           // Previously: ADOPTANTE
  DONOR = 'DONOR',               // Previously: DONANTE
  VETERINARIAN = 'VETERINARIAN', // Previously: VETERINARIO
}

registerEnumType(UserRole, {
  name: 'UserRole',
});
