import { registerEnumType } from '@nestjs/graphql';

export enum AnimalSize {
  SMALL = 'SMALL',
  MEDIUM = 'MEDIUM',
  LARGE = 'LARGE',
}

registerEnumType(AnimalSize, { name: 'AnimalSize' });
