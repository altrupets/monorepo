import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { ObjectType, Field, ID } from '@nestjs/graphql';
import { User } from '../../users/entities/user.entity';
import { AdoptionListing } from './adoption-listing.entity';
import { ApplicationStatus } from '../enums/application-status.enum';

@ObjectType()
@Entity('adoption_applications')
@Unique(['listingId', 'applicantUserId'])
export class AdoptionApplication {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  listingId: string;

  @Field(() => AdoptionListing)
  @ManyToOne(() => AdoptionListing)
  @JoinColumn({ name: 'listingId' })
  listing: AdoptionListing;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  applicantUserId: string;

  @Field(() => User)
  @ManyToOne(() => User)
  @JoinColumn({ name: 'applicantUserId' })
  applicant: User;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  reviewerUserId?: string;

  @Field(() => User, { nullable: true })
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'reviewerUserId' })
  reviewer?: User;

  @Field(() => ApplicationStatus)
  @Column({
    type: 'enum',
    enum: ApplicationStatus,
    default: ApplicationStatus.SUBMITTED,
  })
  status: ApplicationStatus;

  @Field()
  @Column({ type: 'text' })
  homeDescription: string;

  @Field()
  @Column({ type: 'text' })
  familyDescription: string;

  @Field()
  @Column({ type: 'text' })
  petExperience: string;

  @Field()
  @Column()
  contactPhone: string;

  @Field()
  @Column({ type: 'text' })
  motivation: string;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  reviewerNotes?: string;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  rejectionReason?: string;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  visitScheduledAt?: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  visitCompletedAt?: Date;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  visitNotes?: string;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
