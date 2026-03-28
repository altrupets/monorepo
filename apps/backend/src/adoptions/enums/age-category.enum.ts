import { registerEnumType } from '@nestjs/graphql';

export enum AgeCategory {
  PUPPY_KITTEN = 'PUPPY_KITTEN',
  YOUNG = 'YOUNG',
  ADULT = 'ADULT',
  SENIOR = 'SENIOR',
}

registerEnumType(AgeCategory, { name: 'AgeCategory' });
