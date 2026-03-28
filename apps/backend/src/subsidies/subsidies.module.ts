import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SubsidyRequest } from './entities/subsidy-request.entity';
import { SubsidiesService } from './subsidies.service';
import { SubsidiesResolver } from './subsidies.resolver';
import { SubsidyExpiryJob } from './jobs/subsidy-expiry.job';
import { JurisdictionsModule } from '../jurisdictions/jurisdictions.module';
import { Animal } from '../animals/entities/animal.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([SubsidyRequest, Animal]),
    JurisdictionsModule,
    NotificationsModule,
  ],
  providers: [SubsidiesService, SubsidiesResolver, SubsidyExpiryJob],
  exports: [SubsidiesService],
})
export class SubsidiesModule {}
