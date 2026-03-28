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
import { ObjectType, Field, ID } from '@nestjs/graphql';
import { Point } from '../../types/geometry.types';
import { Animal } from '../../animals/entities/animal.entity';
import { User } from '../../users/entities/user.entity';
import { ListingStatus } from '../enums/listing-status.enum';

@ObjectType()
@Entity('adoption_listings')
export class AdoptionListing {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid', unique: true })
  @Index()
  animalId: string;

  @Field(() => Animal)
  @ManyToOne(() => Animal)
  @JoinColumn({ name: 'animalId' })
  animal: Animal;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  publisherId: string;

  @Field(() => User)
  @ManyToOne(() => User)
  @JoinColumn({ name: 'publisherId' })
  publisher: User;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  casaCunaId?: string;

  @Field(() => ListingStatus)
  @Column({
    type: 'enum',
    enum: ListingStatus,
    default: ListingStatus.DRAFT,
  })
  status: ListingStatus;

  @Field()
  @Column()
  title: string;

  @Field()
  @Column({ type: 'text' })
  description: string;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  requirements?: string;

  @Field(() => [String], { nullable: true })
  @Column({ type: 'simple-array', nullable: true })
  temperament?: string[];

  @Field()
  @Column({ default: false })
  isChildFriendly: boolean;

  @Field()
  @Column({ default: false })
  isPetFriendly: boolean;

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

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  publishedAt?: Date;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  closedAt?: Date;
}
