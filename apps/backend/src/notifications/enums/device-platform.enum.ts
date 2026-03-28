import { registerEnumType } from '@nestjs/graphql';

export enum DevicePlatform {
  ANDROID = 'ANDROID',
  IOS = 'IOS',
  WEB = 'WEB',
}

registerEnumType(DevicePlatform, { name: 'DevicePlatform' });
