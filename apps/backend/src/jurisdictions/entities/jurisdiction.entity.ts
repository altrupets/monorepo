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
import { ObjectType, Field, ID, Float } from '@nestjs/graphql';

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

  @Field({ nullable: true })
  @Column({ type: 'float', nullable: true })
  latitude?: number;

  @Field({ nullable: true })
  @Column({ type: 'float', nullable: true })
  longitude?: number;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
