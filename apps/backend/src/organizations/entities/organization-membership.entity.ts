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
import { Organization } from './organization.entity';
import { User } from '../../users/entities/user.entity';

export enum MembershipStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  REVOKED = 'REVOKED',
}

export enum OrganizationRole {
  LEGAL_REPRESENTATIVE = 'LEGAL_REPRESENTATIVE',
  USER_ADMIN = 'USER_ADMIN',
  MEMBER = 'MEMBER',
}

@ObjectType()
@Entity('organization_memberships')
@Index(['organizationId', 'userId'], { unique: true })
export class OrganizationMembership {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => ID)
  @Column({ type: 'uuid' })
  @Index()
  organizationId: string;

  @ManyToOne(() => Organization, (org) => org.memberships)
  @JoinColumn({ name: 'organizationId' })
  organization: Organization;

  @Field(() => ID)
  @Column({ type: 'uuid' })
  @Index()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Field(() => String)
  @Column({
    type: 'enum',
    enum: MembershipStatus,
    default: MembershipStatus.PENDING,
  })
  status: MembershipStatus;

  @Field(() => String)
  @Column({
    type: 'enum',
    enum: OrganizationRole,
    default: OrganizationRole.MEMBER,
  })
  role: OrganizationRole;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  requestMessage?: string;

  @Field({ nullable: true })
  @Column({ type: 'text', nullable: true })
  rejectionReason?: string;

  @Field({ nullable: true })
  @Column({ type: 'uuid', nullable: true })
  approvedBy?: string;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  approvedAt?: Date;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
