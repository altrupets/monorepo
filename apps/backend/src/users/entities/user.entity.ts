import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { ObjectType, Field, ID, Float } from '@nestjs/graphql';
import { UserRole } from '../../auth/roles/user-role.enum';

@ObjectType()
@Entity('users')
export class User {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column({ unique: true })
  @Index()
  username: string;

  @Field({ nullable: true })
  @Column({ unique: true, nullable: true })
  @Index()
  email?: string;

  @Column()
  passwordHash: string;

  @Field(() => [UserRole])
  @Column({
    type: 'enum',
    enum: UserRole,
    array: true,
    default: [UserRole.WATCHER],
  })
  roles: UserRole[];

  @Field({ nullable: true })
  @Column({ nullable: true })
  firstName?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  lastName?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  identification?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  country?: string;

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
  @Column({ nullable: true })
  bio?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  occupation?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  incomeSource?: string;

  @Field({ nullable: true })
  @Column({ type: 'uuid', nullable: true })
  organizationId?: string;

  @Field(() => Float, { nullable: true })
  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude?: number;

  @Field(() => Float, { nullable: true })
  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude?: number;

  @Field()
  @Column({ default: true })
  isActive: boolean;

  @Field()
  @Column({ default: false })
  isVerified: boolean;

  @Column({ type: 'bytea', nullable: true })
  avatarImage?: Buffer | null;

  @Field(() => String, { nullable: true })
  avatarBase64?: string | null;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
