import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AbuseReport } from './entities/abuse-report.entity';
import { AbuseReportsService } from './abuse-reports.service';
import { AbuseReportsResolver } from './abuse-reports.resolver';
import { JurisdictionsModule } from '../jurisdictions/jurisdictions.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([AbuseReport]),
    JurisdictionsModule,
    NotificationsModule,
  ],
  providers: [AbuseReportsService, AbuseReportsResolver],
  exports: [AbuseReportsService],
})
export class AbuseReportsModule {}
