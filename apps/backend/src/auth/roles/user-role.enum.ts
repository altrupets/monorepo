import { registerEnumType } from '@nestjs/graphql';

export enum UserRole {
  // Administrative Roles
  GOVERNMENT_ADMIN = 'GOVERNMENT_ADMIN',
  ANIMAL_WELFARE_OFFICER = 'ANIMAL_WELFARE_OFFICER',
  CONFLICT_MEDIATOR = 'CONFLICT_MEDIATOR',

  // Organizational Roles
  LEGAL_REPRESENTATIVE = 'LEGAL_REPRESENTATIVE',
  USER_ADMIN = 'USER_ADMIN',

  // Operational Roles (Individual or Organizational)
  CENTINELA = 'CENTINELA',
  AUXILIAR = 'AUXILIAR',
  RESCATISTA = 'RESCATISTA',
  ADOPTANTE = 'ADOPTANTE',
  DONANTE = 'DONANTE',
  VETERINARIO = 'VETERINARIO',
}

registerEnumType(UserRole, {
  name: 'UserRole',
});
