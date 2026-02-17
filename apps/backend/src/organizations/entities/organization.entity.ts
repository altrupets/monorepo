import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  OneToMany,
} from 'typeorm';
import { ObjectType, Field, ID } from '@nestjs/graphql';
import { OrganizationMembership } from './organization-membership.entity';

export enum OrganizationType {
  FOUNDATION = 'FOUNDATION',
  ASSOCIATION = 'ASSOCIATION',
  NGO = 'NGO',
  COOPERATIVE = 'COOPERATIVE',
  GOVERNMENT = 'GOVERNMENT',
  OTHER = 'OTHER',
}

export enum OrganizationStatus {
  PENDING_VERIFICATION = 'PENDING_VERIFICATION',
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
  INACTIVE = 'INACTIVE',
}

@ObjectType()
@Entity('organizations')
export class Organization {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column({ unique: true })
  @Index()
  name: string;

  @Field(() => String)
  @Column({
    type: 'enum',
    enum: OrganizationType,
    default: OrganizationType.ASSOCIATION,
  })
  type: OrganizationType;

  @Field({ nullable: true })
  @Column({ nullable: true })
  legalId?: string; // Cédula jurídica

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  description?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  email?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  website?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  address?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  country?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  province?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  canton?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  district?: string;

  @Field(() => String)
  @Column({
    type: 'enum',
    enum: OrganizationStatus,
    default: OrganizationStatus.PENDING_VERIFICATION,
  })
  status: OrganizationStatus;

  // Legal documentation stored as bytea (binary)
  @Column({ type: 'bytea', nullable: true })
  legalDocumentation?: Buffer | null;

  @Field(() => String, { nullable: true })
  legalDocumentationBase64?: string | null;

  // Financial statements stored as bytea (binary)
  @Column({ type: 'bytea', nullable: true })
  financialStatements?: Buffer | null;

  @Field(() => String, { nullable: true })
  financialStatementsBase64?: string | null;

  @Field({ nullable: true })
  @Column({ type: 'uuid', nullable: true })
  legalRepresentativeId?: string;

  @Field()
  @Column({ default: 0 })
  memberCount: number;

  @Field()
  @Column({ default: 0 })
  maxCapacity: number;

  @Field()
  @Column({ default: true })
  isActive: boolean;

  @Field()
  @Column({ default: false })
  isVerified: boolean;

  @OneToMany(
    () => OrganizationMembership,
    (membership) => membership.organization,
  )
  memberships: OrganizationMembership[];

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
