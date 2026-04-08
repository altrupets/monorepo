import { ObjectType, Field, ID } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Campaign } from './campaign.entity';
import { RegistrationStatus, AnimalSpecies, AnimalSex } from '../enums/registration-status.enum';

@ObjectType()
@Entity('campaign_registrations')
export class CampaignRegistration {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  campaignId: string;

  @Field(() => Campaign)
  @ManyToOne(() => Campaign, (campaign) => campaign.registrations)
  @JoinColumn({ name: 'campaignId' })
  campaign: Campaign;

  @Field(() => String)
  @Column({ type: 'varchar' })
  ownerName: string;

  @Field(() => String)
  @Column({ type: 'varchar' })
  ownerPhone: string;

  @Field(() => String)
  @Column({ type: 'varchar' })
  animalName: string;

  @Field(() => AnimalSpecies)
  @Column({
    type: 'enum',
    enum: AnimalSpecies,
  })
  animalSpecies: AnimalSpecies;

  @Field(() => String, { nullable: true })
  @Column({ type: 'varchar', nullable: true })
  animalBreed?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'varchar', nullable: true })
  animalAge?: string;

  @Field(() => AnimalSex)
  @Column({
    type: 'enum',
    enum: AnimalSex,
  })
  animalSex: AnimalSex;

  @Field(() => RegistrationStatus)
  @Column({
    type: 'enum',
    enum: RegistrationStatus,
    default: RegistrationStatus.REGISTERED,
  })
  status: RegistrationStatus;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  operatedById?: string;

  @Field(() => User, { nullable: true })
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'operatedById' })
  operatedBy?: User;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  operatedAt?: Date;

  @Field(() => String, { nullable: true })
  @Column({ type: 'text', nullable: true })
  notes?: string;

  @Field()
  @CreateDateColumn()
  createdAt: Date;
}
