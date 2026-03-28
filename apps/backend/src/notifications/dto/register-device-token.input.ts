import { InputType, Field } from '@nestjs/graphql';
import { IsNotEmpty, IsString } from 'class-validator';
import { DevicePlatform } from '../enums/device-platform.enum.js';

@InputType()
export class RegisterDeviceTokenInput {
  @Field()
  @IsString()
  @IsNotEmpty()
  token: string;

  @Field(() => DevicePlatform)
  platform: DevicePlatform;
}
