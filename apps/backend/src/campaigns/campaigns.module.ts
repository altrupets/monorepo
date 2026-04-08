import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Campaign } from './entities/campaign.entity';
import { CampaignRegistration } from './entities/campaign-registration.entity';
import { CampaignsService } from './campaigns.service';
import { CampaignsResolver } from './campaigns.resolver';

@Module({
  imports: [
    TypeOrmModule.forFeature([Campaign, CampaignRegistration]),
  ],
  providers: [CampaignsService, CampaignsResolver],
  exports: [CampaignsService],
})
export class CampaignsModule {}
