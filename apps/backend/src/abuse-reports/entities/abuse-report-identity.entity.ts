import { ObjectType, Field, ID } from '@nestjs/graphql';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { AbuseReport } from './abuse-report.entity';

@ObjectType()
@Entity('abuse_report_identities')
export class AbuseReportIdentity {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field(() => String)
  @Column({ type: 'uuid', unique: true })
  abuseReportId: string;

  @OneToOne(() => AbuseReport, (report) => report.identity)
  @JoinColumn({ name: 'abuseReportId' })
  abuseReport: AbuseReport;

  @Field(() => String)
  @Column({ type: 'varchar' })
  fullName: string;

  @Field(() => String)
  @Column({ type: 'varchar' })
  identificationNumber: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'varchar', nullable: true })
  phone?: string;

  @Field(() => String, { nullable: true })
  @Column({ type: 'varchar', nullable: true })
  email?: string;

  @Field(() => Boolean)
  @Column({ type: 'boolean', default: false })
  consentGiven: boolean;

  @Field()
  @CreateDateColumn()
  createdAt: Date;
}
