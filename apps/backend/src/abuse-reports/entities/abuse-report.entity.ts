import { ObjectType, Field, ID, Float } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Organization } from '../../organizations/entities/organization.entity';
import { User } from '../../users/entities/user.entity';
import { AbuseReportStatus } from '../enums/abuse-report-status.enum';
import { PrivacyMode } from '../enums/privacy-mode.enum';
import { AbuseReportPriority } from '../enums/abuse-report-priority.enum';
import { AbuseReportIdentity } from './abuse-report-identity.entity';

@ObjectType()
@Entity('abuse_reports')
export class AbuseReport {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'varchar', unique: true })
  @Index()
  trackingCode: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  municipalityId?: string;

  @Field(() => Organization, { nullable: true })
  @ManyToOne(() => Organization)
  @JoinColumn({ name: 'municipalityId' })
  municipality?: Organization;

  @Field(() => AbuseReportStatus)
  @Column({
    type: 'enum',
    enum: AbuseReportStatus,
    default: AbuseReportStatus.FILED,
  })
  status: AbuseReportStatus;

  @Field(() => [String])
  @Column('varchar', { array: true })
  abuseTypes: string[];

  @Field(() => String)
  @Column({ type: 'text' })
  description: string;

  @Field(() => String)
  @Column({ type: 'varchar' })
  locationProvince: string;

  @Field(() => String)
  @Column({ type: 'varchar' })
  locationCanton: string;

  @Field(() => String)
  @Column({ type: 'varchar' })
  locationDistrict: string;

  @Field(() => String)
  @Column({ type: 'text' })
  locationAddress: string;

  @Field(() => Float, { nullable: true })
  @Column('decimal', { precision: 10, scale: 7, nullable: true })
  latitude?: number;

  @Field(() => Float, { nullable: true })
  @Column('decimal', { precision: 10, scale: 7, nullable: true })
  longitude?: number;

  @Field(() => [String])
  @Column('varchar', { array: true, default: '{}' })
  evidenceUrls: string[];

  @Field(() => PrivacyMode)
  @Column({
    type: 'enum',
    enum: PrivacyMode,
    default: PrivacyMode.ANONYMOUS,
  })
  privacyMode: PrivacyMode;

  @Field(() => AbuseReportPriority)
  @Column({
    type: 'enum',
    enum: AbuseReportPriority,
    default: AbuseReportPriority.MEDIUM,
  })
  priority: AbuseReportPriority;

  @Field(() => String, { nullable: true })
  @Column({ type: 'varchar', nullable: true })
  classifiedAs?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  assignedToId?: string;

  @Field(() => User, { nullable: true })
  @ManyToOne(() => User)
  @JoinColumn({ name: 'assignedToId' })
  assignedTo?: User;

  @Field(() => Date, { nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  resolvedAt?: Date;

  @Field(() => String, { nullable: true })
  @Column({ type: 'text', nullable: true })
  resolutionNotes?: string;

  @OneToOne(() => AbuseReportIdentity, (identity) => identity.abuseReport)
  identity?: AbuseReportIdentity;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
