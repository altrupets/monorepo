import { ObjectType, Field, ID, registerEnumType } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Organization } from '../../organizations/entities/organization.entity';
import { Point } from '../../types/geometry.types';

export enum AbuseReportType {
  PHYSICAL_ABUSE = 'PHYSICAL_ABUSE',
  ABANDONMENT = 'ABANDONMENT',
  NEGLECT = 'NEGLECT',
  DANGEROUS_ANIMAL = 'DANGEROUS_ANIMAL',
  OTHER = 'OTHER',
}

export enum AbuseReportStatus {
  SUBMITTED = 'SUBMITTED',
  UNDER_REVIEW = 'UNDER_REVIEW',
  INVESTIGATING = 'INVESTIGATING',
  RESOLVED = 'RESOLVED',
  DISMISSED = 'DISMISSED',
}

registerEnumType(AbuseReportType, { name: 'AbuseReportType' });
registerEnumType(AbuseReportStatus, { name: 'AbuseReportStatus' });

@ObjectType()
@Entity('abuse_reports')
export class AbuseReport {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => AbuseReportType)
  @Column({
    type: 'enum',
    enum: AbuseReportType,
    default: AbuseReportType.OTHER,
  })
  type: AbuseReportType;

  @Field(() => String, { nullable: true })
  @Column({ type: 'text', nullable: true })
  description?: string;

  @Field(() => Point)
  @Index({ spatial: true })
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
  })
  location: Point;

  @Field(() => [String])
  @Column('simple-array', { nullable: true })
  photos: string[];

  @Field(() => String)
  @Column({ unique: true })
  @Index()
  trackingCode: string;

  @Field(() => AbuseReportStatus)
  @Column({
    type: 'enum',
    enum: AbuseReportStatus,
    default: AbuseReportStatus.SUBMITTED,
  })
  status: AbuseReportStatus;

  @Field(() => String)
  @Column()
  reporterId: string;

  @Field(() => User)
  @ManyToOne(() => User)
  @JoinColumn({ name: 'reporterId' })
  reporter: User;

  @Field(() => String, { nullable: true })
  @Column({ nullable: true })
  @Index()
  municipalityId?: string;

  @Field(() => Organization, { nullable: true })
  @ManyToOne(() => Organization)
  @JoinColumn({ name: 'municipalityId' })
  municipality?: Organization;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
