import { ObjectType, Field, ID } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { SubsidyRequest, SubsidyRequestStatus } from './subsidy-request.entity';
import { AuditAction } from '../enums/audit-action.enum';
import { GraphQLJSON } from '../../notifications/scalars/json.scalar';

@ObjectType()
@Entity('approval_audit_log')
export class ApprovalAuditLog {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  subsidyRequestId: string;

  @Field(() => SubsidyRequest)
  @ManyToOne(() => SubsidyRequest)
  @JoinColumn({ name: 'subsidyRequestId' })
  subsidyRequest: SubsidyRequest;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  actorId?: string;

  @Field(() => User, { nullable: true })
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'actorId' })
  actor?: User;

  @Field(() => AuditAction)
  @Column({
    type: 'enum',
    enum: AuditAction,
  })
  action: AuditAction;

  @Field(() => GraphQLJSON, { nullable: true })
  @Column({ type: 'jsonb', nullable: true })
  ruleResults?: Record<string, any>;

  @Field(() => SubsidyRequestStatus, { nullable: true })
  @Column({
    type: 'enum',
    enum: SubsidyRequestStatus,
    nullable: true,
  })
  previousStatus?: SubsidyRequestStatus;

  @Field(() => SubsidyRequestStatus, { nullable: true })
  @Column({
    type: 'enum',
    enum: SubsidyRequestStatus,
    nullable: true,
  })
  newStatus?: SubsidyRequestStatus;

  @Field(() => String, { nullable: true })
  @Column({ type: 'text', nullable: true })
  notes?: string;

  @Field()
  @CreateDateColumn()
  createdAt: Date;
}
