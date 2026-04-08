import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SubsidyRequest } from './entities/subsidy-request.entity';
import { AutoApprovalRule } from './entities/auto-approval-rule.entity';
import { ApprovalAuditLog } from './entities/approval-audit-log.entity';
import { SubsidiesService } from './subsidies.service';
import { SubsidiesResolver } from './subsidies.resolver';
import { AutoApprovalEngineService } from './auto-approval-engine.service';
import { SubsidyExpiryJob } from './jobs/subsidy-expiry.job';
import { JurisdictionsModule } from '../jurisdictions/jurisdictions.module';
import { Animal } from '../animals/entities/animal.entity';
import { User } from '../users/entities/user.entity';
import { VetProfile } from '../vet-profiles/entities/vet-profile.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SubsidyRequest,
      AutoApprovalRule,
      ApprovalAuditLog,
      Animal,
      User,
      VetProfile,
    ]),
    JurisdictionsModule,
    NotificationsModule,
  ],
  providers: [
    SubsidiesService,
    SubsidiesResolver,
    AutoApprovalEngineService,
    SubsidyExpiryJob,
  ],
  exports: [SubsidiesService],
})
export class SubsidiesModule {}
