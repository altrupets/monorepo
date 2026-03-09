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
import { MultiPolygon, Point } from '../../types/geometry.types';

export enum JurisdictionLevel {
  PROVINCE = 'PROVINCE',
  CANTON = 'CANTON',
  DISTRICT = 'DISTRICT',
}

@ObjectType()
@Entity('jurisdictions')
export class Jurisdiction {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column()
  name: string;

  @Field(() => JurisdictionLevel)
  @Column({
    type: 'enum',
    enum: JurisdictionLevel,
  })
  level: JurisdictionLevel;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  parentId?: string;

  @Field(() => Jurisdiction, { nullable: true })
  @ManyToOne(() => Jurisdiction, { nullable: true })
  @JoinColumn({ name: 'parentId' })
  parent?: Jurisdiction;

  @Field({ nullable: true })
  @Column({ nullable: true })
  province?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  canton?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  district?: string;

  @Field(() => MultiPolygon, { nullable: true })
  @Column({
    type: 'geometry',
    spatialFeatureType: 'MultiPolygon',
    srid: 4326,
    nullable: true,
  })
  geometry?: any;

  @Field(() => String, { nullable: true })
  @Column({ nullable: true })
  @Index()
  organizationId?: string;

  @Field(() => Point, { nullable: true })
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  centerPoint?: any;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
