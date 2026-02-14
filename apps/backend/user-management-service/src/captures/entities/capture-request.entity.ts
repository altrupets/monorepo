import { Field, ID, ObjectType, Float } from '@nestjs/graphql';
import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
} from 'typeorm';

@ObjectType()
@Entity('capture_requests')
export class CaptureRequest {
    @Field(() => ID)
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Field(() => Float)
    @Column('decimal', { precision: 10, scale: 7 })
    latitude: number;

    @Field(() => Float)
    @Column('decimal', { precision: 10, scale: 7 })
    longitude: number;

    @Field({ nullable: true })
    @Column({ nullable: true })
    description?: string;

    @Field()
    @Column()
    animalType: string;

    @Field()
    @Column({ default: 'PENDING' })
    status: string;

    @Field()
    @Column()
    imageUrl: string;

    @Field()
    @CreateDateColumn()
    createdAt: Date;
}
