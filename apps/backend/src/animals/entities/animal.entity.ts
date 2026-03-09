import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { ObjectType, Field, ID, Float } from '@nestjs/graphql';

export enum AnimalSpecies {
  DOG = 'DOG',
  CAT = 'CAT',
  OTHER = 'OTHER',
}

export enum AnimalStatus {
  RESCUED = 'RESCUED',
  IN_CASA_CUNA = 'IN_CASA_CUNA',
  ADOPTED = 'ADOPTED',
  RETURNED = 'RETURNED',
}

@ObjectType()
@Entity('animals')
export class Animal {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column()
  name: string;

  @Field(() => AnimalSpecies)
  @Column({
    type: 'enum',
    enum: AnimalSpecies,
  })
  species: AnimalSpecies;

  @Field({ nullable: true })
  @Column({ nullable: true })
  breed?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  age?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  gender?: string;

  @Field(() => AnimalStatus)
  @Column({
    type: 'enum',
    enum: AnimalStatus,
    default: AnimalStatus.RESCUED,
  })
  status: AnimalStatus;

  @Field({ nullable: true })
  @Column({ nullable: true, type: 'text' })
  description?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  imageUrl?: string;

  @Field(() => Float, { nullable: true })
  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude?: number;

  @Field(() => Float, { nullable: true })
  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude?: number;

  @Field({ nullable: true })
  @Column({ nullable: true })
  rescueLocation?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  casaCunaId?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  rescuerId?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  veterinaryNotes?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  vaccinationStatus?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  microchipId?: string;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
