import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { nanoid } from 'nanoid';
import { AbuseReport, AbuseReportStatus } from './entities/abuse-report.entity';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/enums/notification-type.enum';
import { UserRole } from '../auth/roles/user-role.enum';

@Injectable()
export class AbuseReportsService {
  constructor(
    @InjectRepository(AbuseReport)
    private readonly abuseReportRepository: Repository<AbuseReport>,
    private readonly jurisdictionsService: JurisdictionsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async create(data: {
    type: string;
    description?: string;
    latitude: number;
    longitude: number;
    photos?: string[];
    reporterId: string;
  }): Promise<AbuseReport> {
    // 1. Generate tracking code
    const trackingCode = nanoid(10).toUpperCase();

    // 2. Find municipality by GPS
    const jurisdiction = await this.jurisdictionsService.findByCoordinates(
      data.latitude,
      data.longitude,
    );

    // 3. Create report
    const report = this.abuseReportRepository.create({
      type: data.type as any,
      description: data.description,
      location: {
        type: 'Point',
        coordinates: [data.longitude, data.latitude],
      },
      photos: data.photos || [],
      trackingCode,
      reporterId: data.reporterId,
      municipalityId: jurisdiction?.organizationId, // Ensure Jurisdiction has organizationId or mapping
      status: AbuseReportStatus.SUBMITTED,
    });

    const saved = await this.abuseReportRepository.save(report);

    // Notify government admins about new abuse report
    this.notificationsService
      .sendToRole({
        role: UserRole.GOVERNMENT_ADMIN,
        type: NotificationType.ABUSE_REPORT_FILED,
        title: 'New Abuse Report Filed',
        body: `A new ${data.type} abuse report has been filed (${trackingCode})`,
        referenceId: saved.id,
        referenceType: 'AbuseReport',
        jurisdictionId: saved.municipalityId,
      })
      .catch(() => {
        // Notification failures should not block the main flow
      });

    return saved;
  }

  async findByTrackingCode(code: string): Promise<AbuseReport> {
    const report = await this.abuseReportRepository.findOne({
      where: { trackingCode: code.toUpperCase() },
      relations: ['reporter', 'municipality'],
    });

    if (!report) {
      throw new NotFoundException(`Report with tracking code ${code} not found`);
    }

    return report;
  }

  async findAllByMunicipality(municipalityId: string): Promise<AbuseReport[]> {
    return this.abuseReportRepository.find({
      where: { municipalityId },
      order: { createdAt: 'DESC' },
    });
  }

  async updateStatus(
    id: string,
    status: AbuseReportStatus,
  ): Promise<AbuseReport> {
    const report = await this.abuseReportRepository.findOne({ where: { id } });
    if (!report) {
      throw new NotFoundException(`Report with ID ${id} not found`);
    }

    report.status = status;
    const saved = await this.abuseReportRepository.save(report);

    // Notify the reporter about the status update
    this.notificationsService
      .sendToUser({
        userId: saved.reporterId,
        type: NotificationType.ABUSE_REPORT_UPDATE,
        title: 'Abuse Report Updated',
        body: `Your abuse report (${saved.trackingCode}) status changed to ${status}`,
        referenceId: saved.id,
        referenceType: 'AbuseReport',
      })
      .catch(() => {
        // Notification failures should not block the main flow
      });

    return saved;
  }
}
