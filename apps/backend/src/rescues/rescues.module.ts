import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RescueAlert } from './entities/rescue-alert.entity';
import { RescuesService } from './rescues.service';
import { RescueMatchingService } from './rescue-matching.service';
import { RescueStateMachine } from './rescue-state-machine';
import { RescuesResolver } from './rescues.resolver';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([RescueAlert]),
    NotificationsModule,
  ],
  providers: [
    RescuesService,
    RescueMatchingService,
    RescueStateMachine,
    RescuesResolver,
  ],
  exports: [RescuesService],
})
export class RescuesModule {}
