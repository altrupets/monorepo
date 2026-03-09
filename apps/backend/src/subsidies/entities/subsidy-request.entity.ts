import { ObjectType, Field, ID, registerEnumType, Float } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Organization } from '../../organizations/entities/organization.entity';
import { Animal } from '../../animals/entities/animal.entity';

export enum SubsidyRequestStatus {
  CREATED = 'CREATED',
  IN_REVIEW = 'IN_REVIEW',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  EXPIRED = 'EXPIRED',
  PAID = 'PAID',
}

registerEnumType(SubsidyRequestStatus, { name: 'SubsidyRequestStatus' });

@ObjectType()
@Entity('subsidy_requests')
export class SubsidyRequest {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column()
  animalId: string;

  @Field(() => Animal)
  @ManyToOne(() => Animal)
  @JoinColumn({ name: 'animalId' })
  animal: Animal;

  @Field(() => String)
  @Column()
  requesterId: string;

  @Field(() => User)
  @ManyToOne(() => User)
  @JoinColumn({ name: 'requesterId' })
  requester: User;

  @Field(() => String, { nullable: true })
  @Column({ nullable: true })
  @Index()
  municipalityId?: string;

  @Field(() => Organization, { nullable: true })
  @ManyToOne(() => Organization)
  @JoinColumn({ name: 'municipalityId' })
  municipality?: Organization;

  @Field(() => Float)
  @Column('decimal', { precision: 12, scale: 2 })
  amountRequested: number;

  @Field(() => String)
  @Column('text')
  justification: string;

  @Field(() => SubsidyRequestStatus)
  @Column({
    type: 'enum',
    enum: SubsidyRequestStatus,
    default: SubsidyRequestStatus.CREATED,
  })
  status: SubsidyRequestStatus;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  expiresAt?: Date;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
