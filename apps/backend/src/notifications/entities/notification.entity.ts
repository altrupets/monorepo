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
import { User } from '../../users/entities/user.entity.js';
import { NotificationType } from '../enums/notification-type.enum.js';
import { GraphQLJSON } from '../scalars/json.scalar.js';

@ObjectType()
@Entity('notifications')
@Index(['userId', 'isRead'])
export class Notification {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column({ type: 'uuid' })
  @Index()
  userId: string;

  @Field(() => User)
  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Field(() => NotificationType)
  @Column({
    type: 'enum',
    enum: NotificationType,
  })
  type: NotificationType;

  @Field()
  @Column()
  title: string;

  @Field()
  @Column('text')
  body: string;

  @Field(() => GraphQLJSON, { nullable: true })
  @Column({ type: 'jsonb', nullable: true })
  data?: Record<string, unknown>;

  @Field({ nullable: true })
  @Column({ nullable: true })
  @Index()
  referenceId?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  referenceType?: string;

  @Field()
  @Column({ default: false })
  isRead: boolean;

  @Field()
  @Column({ default: false })
  pushSent: boolean;

  @Field({ nullable: true })
  @Column({ type: 'timestamp', nullable: true })
  pushSentAt?: Date;

  @Field({ nullable: true })
  @Column({ nullable: true })
  pushError?: string;

  @Field()
  @CreateDateColumn()
  createdAt: Date;
}
