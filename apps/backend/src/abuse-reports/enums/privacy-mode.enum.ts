import { registerEnumType } from '@nestjs/graphql';

export enum PrivacyMode {
  ANONYMOUS = 'ANONYMOUS',
  PUBLIC = 'PUBLIC',
  CONFIDENTIAL = 'CONFIDENTIAL',
}

registerEnumType(PrivacyMode, { name: 'PrivacyMode' });
