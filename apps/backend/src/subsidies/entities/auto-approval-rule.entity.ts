import { ObjectType, Field, ID } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { Organization } from '../../organizations/entities/organization.entity';
import { AutoApprovalRuleType } from '../enums/auto-approval-rule-type.enum';
import { GraphQLJSON } from '../../notifications/scalars/json.scalar';

@ObjectType()
@Entity('auto_approval_rules')
@Unique(['municipalityId', 'ruleType'])
export class AutoApprovalRule {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  municipalityId: string;

  @Field(() => Organization)
  @ManyToOne(() => Organization)
  @JoinColumn({ name: 'municipalityId' })
  municipality: Organization;

  @Field(() => AutoApprovalRuleType)
  @Column({
    type: 'enum',
    enum: AutoApprovalRuleType,
  })
  ruleType: AutoApprovalRuleType;

  @Field(() => Boolean)
  @Column({ type: 'boolean', default: true })
  isEnabled: boolean;

  @Field(() => GraphQLJSON, { nullable: true })
  @Column({ type: 'jsonb', nullable: true })
  parameters?: Record<string, any>;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
