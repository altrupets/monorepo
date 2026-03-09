import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  Index,
  JoinColumn,
} from 'typeorm';
import { ObjectType, Field, ID, Int } from '@nestjs/graphql';
import { Organization } from './organization.entity';
import { Animal } from '../../animals/entities/animal.entity';
import { NeedsListItem } from './needs-list-item.entity';
import { Point } from '../../types/geometry.types';

@ObjectType()
@Entity('casa_cunas')
export class CasaCuna {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column()
  name: string;

  @Field(() => Int)
  @Column({ default: 0 })
  capacity: number;

  @Field(() => Int)
  @Column({ default: 0 })
  currentOccupancy: number;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  description?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  address?: string;

  @Field(() => Point, { nullable: true })
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location?: any;

  @Field()
  @Column({ default: true })
  isActive: boolean;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  organizationId: string;

  @ManyToOne(() => Organization, (org) => org.id)
  @JoinColumn({ name: 'organizationId' })
  organization: Organization;

  @Field(() => [Animal], { nullable: true })
  @OneToMany(() => Animal, (animal) => animal.id)
  animals?: Animal[];

  @Field(() => [NeedsListItem], { nullable: true })
  @OneToMany(() => NeedsListItem, (item) => item.casaCuna)
  needs?: NeedsListItem[];

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
