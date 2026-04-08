import { ObjectType, Field, ID, Int, Float } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Organization } from '../../organizations/entities/organization.entity';
import { CampaignStatus } from '../enums/campaign-status.enum';
import { CampaignRegistration } from './campaign-registration.entity';

@ObjectType()
@Entity('campaigns')
export class Campaign {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  municipalityId: string;

  @Field(() => Organization)
  @ManyToOne(() => Organization)
  @JoinColumn({ name: 'municipalityId' })
  municipality: Organization;

  @Field(() => String)
  @Column({ type: 'varchar' })
  title: string;

  @Field(() => String)
  @Column({ type: 'varchar', unique: true })
  @Index()
  code: string;

  @Field(() => CampaignStatus)
  @Column({
    type: 'enum',
    enum: CampaignStatus,
    default: CampaignStatus.DRAFT,
  })
  status: CampaignStatus;

  @Field(() => String)
  @Column({ type: 'varchar' })
  location: string;

  @Field(() => Int)
  @Column({ type: 'int' })
  maxCapacity: number;

  @Field(() => String)
  @Column({ type: 'date' })
  surgeryDate: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'date', nullable: true })
  promotionDate?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'date', nullable: true })
  registrationOpenDate?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'date', nullable: true })
  registrationCloseDate?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'date', nullable: true })
  orientationDate?: string;

  @Field(() => Float)
  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  budgetAllocated: number;

  @Field(() => Float)
  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  budgetSpent: number;

  @Field(() => [String], { nullable: true })
  @Column('uuid', { array: true, nullable: true })
  veterinarianIds?: string[];

  @Field(() => String, { nullable: true })
  @Column({ type: 'text', nullable: true })
  notes?: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  createdById: string;

  @Field(() => User)
  @ManyToOne(() => User)
  @JoinColumn({ name: 'createdById' })
  createdBy: User;

  @Field(() => [CampaignRegistration], { nullable: true })
  @OneToMany(() => CampaignRegistration, (reg) => reg.campaign)
  registrations?: CampaignRegistration[];

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
