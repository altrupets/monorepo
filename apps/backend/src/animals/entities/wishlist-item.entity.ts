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

export enum WishlistCategory {
  FOOD = 'FOOD',
  MEDICINE = 'MEDICINE',
  SUPPLIES = 'SUPPLIES',
  TOYS = 'TOYS',
  OTHER = 'OTHER',
}

export enum WishlistPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT',
}

@ObjectType()
@Entity('wishlist_items')
export class WishlistItem {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column()
  name: string;

  @Field({ nullable: true })
  @Column({ nullable: true, type: 'text' })
  description?: string;

  @Field(() => WishlistCategory)
  @Column({
    type: 'enum',
    enum: WishlistCategory,
  })
  category: WishlistCategory;

  @Field(() => WishlistPriority)
  @Column({
    type: 'enum',
    enum: WishlistPriority,
    default: WishlistPriority.MEDIUM,
  })
  priority: WishlistPriority;

  @Field({ nullable: true })
  @Column({ nullable: true })
  quantity?: number;

  @Field({ nullable: true })
  @Column({ nullable: true })
  unit?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  estimatedCost?: number;

  @Field({ defaultValue: false })
  @Column({ default: false })
  isPurchased: boolean;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  casaCunaId?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'uuid', nullable: true })
  @Index()
  requestedById?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  purchasedBy?: string;

  @Field({ nullable: true })
  @Column({ nullable: true })
  purchaseDate?: Date;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
