import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdoptionListing } from './entities/adoption-listing.entity';
import { AdoptionApplication } from './entities/adoption-application.entity';
import { AdoptionsService } from './adoptions.service';
import { AdoptionApplicationsService } from './adoption-applications.service';
import { AdoptionsResolver } from './adoptions.resolver';
import { AdoptionApplicationsResolver } from './adoption-applications.resolver';
import { NotificationsModule } from '../notifications/notifications.module';
import { Animal } from '../animals/entities/animal.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([AdoptionListing, AdoptionApplication, Animal]),
    NotificationsModule,
  ],
  providers: [
    AdoptionsService,
    AdoptionApplicationsService,
    AdoptionsResolver,
    AdoptionApplicationsResolver,
  ],
  exports: [AdoptionsService, AdoptionApplicationsService],
})
export class AdoptionsModule {}
