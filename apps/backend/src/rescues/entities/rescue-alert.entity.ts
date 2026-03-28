import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { ObjectType, Field, ID, Int } from '@nestjs/graphql';
import { RescueStatus } from '../enums/rescue-status.enum';
import { RescueUrgency } from '../enums/rescue-urgency.enum';
import { Point } from '../../types/geometry.types';
import { User } from '../../users/entities/user.entity';
import { Animal } from '../../animals/entities/animal.entity';

@ObjectType()
@Entity('rescue_alerts')
@Index(['status'])
@Index(['reportedById'])
@Index(['auxiliarId'])
@Index(['rescuerId'])
export class RescueAlert {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  reportedById: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  auxiliarId?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  rescuerId?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  animalId?: string;

  @Field(() => Point, { nullable: true })
  @Index({ spatial: true })
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location?: any;

  @Field({ nullable: true })
  @Column({ nullable: true })
  locationDescription?: string;

  @Field(() => RescueUrgency)
  @Column({
    type: 'enum',
    enum: RescueUrgency,
  })
  urgency: RescueUrgency;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  description?: string;

  @Field(() => [String], { nullable: true })
  @Column({ type: 'simple-array', nullable: true })
  imageUrls?: string[];

  @Field({ nullable: true })
  @Column({ nullable: true })
  animalType?: string;

  @Field(() => RescueStatus)
  @Column({
    type: 'enum',
    enum: RescueStatus,
    default: RescueStatus.CREATED,
  })
  status: RescueStatus;

  @Field(() => [String], { nullable: true })
  @Column({ type: 'simple-array', nullable: true })
  auxiliarPhotoUrls?: string[];

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  conditionAssessment?: string;

  @Field({ nullable: true })
  @Column({ unique: true, nullable: true })
  trackingCode?: string;

  @Field(() => Int)
  @Column({ type: 'int', default: 10000 })
  searchRadiusMeters: number;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  acceptedAt?: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  transferredAt?: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  completedAt?: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  expiresAt?: Date;

  // Relations
  @Field(() => User, { nullable: true })
  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'reportedById' })
  reportedBy?: User;

  @Field(() => User, { nullable: true })
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'auxiliarId' })
  auxiliar?: User;

  @Field(() => User, { nullable: true })
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'rescuerId' })
  rescuer?: User;

  @Field(() => Animal, { nullable: true })
  @ManyToOne(() => Animal, { nullable: true })
  @JoinColumn({ name: 'animalId' })
  animal?: Animal;
}
