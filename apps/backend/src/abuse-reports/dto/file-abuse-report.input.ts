import { InputType, Field, Float } from '@nestjs/graphql';
import { PrivacyMode } from '../enums/privacy-mode.enum';

@InputType()
export class FileAbuseReportInput {
  @Field(() => [String], { description: 'Array of abuse type codes from ABUSE_TYPES' })
  abuseTypes: string[];

  @Field({ description: 'Detailed description of the observed situation' })
  description: string;

  @Field({ description: 'Province name (e.g. Heredia)' })
  locationProvince: string;

  @Field({ description: 'Canton name (e.g. Heredia)' })
  locationCanton: string;

  @Field({ description: 'District name (e.g. Mercedes)' })
  locationDistrict: string;

  @Field({ description: 'Full address or location reference' })
  locationAddress: string;

  @Field(() => Float, { nullable: true, description: 'GPS latitude (optional)' })
  latitude?: number;

  @Field(() => Float, { nullable: true, description: 'GPS longitude (optional)' })
  longitude?: number;

  @Field(() => [String], { defaultValue: [], description: 'Photo/video URLs' })
  evidenceUrls: string[];

  @Field(() => PrivacyMode, {
    defaultValue: PrivacyMode.ANONYMOUS,
    description: 'Privacy mode: ANONYMOUS, PUBLIC, or CONFIDENTIAL',
  })
  privacyMode: PrivacyMode;

  // Identity fields — only required when privacyMode != ANONYMOUS
  @Field({ nullable: true, description: 'Full name of reporter (required for PUBLIC/CONFIDENTIAL)' })
  fullName?: string;

  @Field({ nullable: true, description: 'Cedula number (required for PUBLIC/CONFIDENTIAL)' })
  identificationNumber?: string;

  @Field({ nullable: true, description: 'Phone number of reporter' })
  phone?: string;

  @Field({ nullable: true, description: 'Email of reporter' })
  email?: string;

  @Field({ nullable: true, description: 'Digital consent checkbox (required for PUBLIC/CONFIDENTIAL)' })
  consentGiven?: boolean;
}
