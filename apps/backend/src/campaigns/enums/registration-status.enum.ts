import { registerEnumType } from '@nestjs/graphql';

export enum RegistrationStatus {
  REGISTERED = 'REGISTERED',
  CHECKED_IN = 'CHECKED_IN',
  OPERATED = 'OPERATED',
  FOLLOW_UP_3D = 'FOLLOW_UP_3D',
  FOLLOW_UP_7D = 'FOLLOW_UP_7D',
  FOLLOW_UP_14D = 'FOLLOW_UP_14D',
  COMPLETED = 'COMPLETED',
}

registerEnumType(RegistrationStatus, { name: 'RegistrationStatus' });

export enum AnimalSpecies {
  DOG = 'DOG',
  CAT = 'CAT',
}

registerEnumType(AnimalSpecies, { name: 'AnimalSpecies' });

export enum AnimalSex {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
}

registerEnumType(AnimalSex, { name: 'AnimalSex' });
