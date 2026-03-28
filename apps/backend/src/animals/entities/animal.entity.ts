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
import { ObjectType, Field, ID, registerEnumType } from '@nestjs/graphql';
import { Point } from '../../types/geometry.types';
import { CasaCuna } from '../../organizations/entities/casa-cuna.entity';
import { AnimalSize } from '../../adoptions/enums/animal-size.enum';
import { AgeCategory } from '../../adoptions/enums/age-category.enum';

export enum AnimalSpecies {
  DOG = 'DOG',
  CAT = 'CAT',
  OTHER = 'OTHER',
}

export enum AnimalStatus {
  RESCUED = 'RESCUED',
  IN_CASA_CUNA = 'IN_CASA_CUNA',
  READY_FOR_ADOPTION = 'READY_FOR_ADOPTION',
  ADOPTED = 'ADOPTED',
  RETURNED = 'RETURNED',
}

registerEnumType(AnimalSpecies, { name: 'AnimalSpecies' });
registerEnumType(AnimalStatus, { name: 'AnimalStatus' });

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

  @Field(() => Point, { nullable: true })
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location?: any;

  @Field({ nullable: true })
  @Column({ nullable: true })
  rescueLocation?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  casaCunaId?: string;

  @Field(() => CasaCuna, { nullable: true })
  @ManyToOne(() => CasaCuna, (casa) => casa.animals, { nullable: true })
  @JoinColumn({ name: 'casaCunaId' })
  casaCuna?: CasaCuna;

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

  @Field(() => AnimalSize, { nullable: true })
  @Column({
    type: 'enum',
    enum: AnimalSize,
    nullable: true,
  })
  size?: AnimalSize;

  @Field(() => AgeCategory, { nullable: true })
  @Column({
    type: 'enum',
    enum: AgeCategory,
    nullable: true,
  })
  ageCategory?: AgeCategory;

  @Field()
  @Column({ default: false })
  isSterilized: boolean;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
