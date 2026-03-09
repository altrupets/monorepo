import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  Index,
  JoinColumn,
} from 'typeorm';
import { ObjectType, Field, ID, registerEnumType } from '@nestjs/graphql';
import { CasaCuna } from './casa-cuna.entity';

export enum NeedCategory {
  FOOD = 'FOOD',
  MEDICINE = 'MEDICINE',
  MONEY = 'MONEY',
  SPACE = 'SPACE',
  OTHER = 'OTHER',
}

registerEnumType(NeedCategory, {
  name: 'NeedCategory',
});

@ObjectType()
@Entity('needs_list_items')
export class NeedsListItem {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column()
  title: string;

  @Field()
  @Column({ type: 'text' })
  description: string;

  @Field(() => NeedCategory)
  @Column({
    type: 'enum',
    enum: NeedCategory,
    default: NeedCategory.OTHER,
  })
  category: NeedCategory;

  @Field()
  @Column({ default: false })
  isFulfilled: boolean;

  @Field(() => String)
  @Column({ type: 'uuid' })
  @Index()
  casaCunaId: string;

  @ManyToOne(() => CasaCuna, (casa) => casa.needs)
  @JoinColumn({ name: 'casaCunaId' })
  casaCuna: CasaCuna;

  @Field()
  @CreateDateColumn()
  createdAt: Date;

  @Field()
  @UpdateDateColumn()
  updatedAt: Date;
}
