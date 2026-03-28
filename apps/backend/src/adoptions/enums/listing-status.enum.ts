import { registerEnumType } from '@nestjs/graphql';

export enum ListingStatus {
  DRAFT = 'DRAFT',
  ACTIVE = 'ACTIVE',
  PAUSED = 'PAUSED',
  ADOPTED = 'ADOPTED',
  WITHDRAWN = 'WITHDRAWN',
}

registerEnumType(ListingStatus, { name: 'ListingStatus' });
