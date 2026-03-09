import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { SubsidiesService } from '../subsidies.service';

@Injectable()
export class SubsidyExpiryJob {
  private readonly logger = new Logger(SubsidyExpiryJob.name);

  constructor(private readonly subsidiesService: SubsidiesService) {}

  @Cron(CronExpression.EVERY_HOUR)
  async handleCron() {
    this.logger.debug('Running Subsidy Expiry Job...');
    const expiredCount = await this.subsidiesService.expireOldRequests();
    if (expiredCount > 0) {
      this.logger.log(`Expired ${expiredCount} subsidy requests.`);
    }
  }
}
