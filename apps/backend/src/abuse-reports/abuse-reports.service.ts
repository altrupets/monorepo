import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AbuseReport } from './entities/abuse-report.entity';
import { AbuseReportIdentity } from './entities/abuse-report-identity.entity';
import { AbuseReportStatus } from './enums/abuse-report-status.enum';
import { PrivacyMode } from './enums/privacy-mode.enum';
import { AbuseReportPriority } from './enums/abuse-report-priority.enum';
import { FileAbuseReportInput } from './dto/file-abuse-report.input';
import { ClassifyReportInput } from './dto/classify-report.input';
import { ResolveReportInput } from './dto/resolve-report.input';
import { ReportMetrics } from './dto/report-metrics.output';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/enums/notification-type.enum';
import { UserRole } from '../auth/roles/user-role.enum';

@Injectable()
export class AbuseReportsService {
  private readonly logger = new Logger(AbuseReportsService.name);
  private reportCodeCounter = 0;

  constructor(
    @InjectRepository(AbuseReport)
    private readonly abuseReportRepository: Repository<AbuseReport>,
    @InjectRepository(AbuseReportIdentity)
    private readonly identityRepository: Repository<AbuseReportIdentity>,
    private readonly jurisdictionsService: JurisdictionsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  // ─── Public mutations ──────────────────────────────────────────

  async fileReport(input: FileAbuseReportInput): Promise<AbuseReport> {
    // 1. Validate identity fields for non-anonymous reports
    if (input.privacyMode !== PrivacyMode.ANONYMOUS) {
      if (!input.fullName || !input.identificationNumber) {
        throw new BadRequestException(
          'Full name and identification number are required for PUBLIC/CONFIDENTIAL reports',
        );
      }
      if (!input.consentGiven) {
        throw new BadRequestException(
          'Consent must be given for PUBLIC/CONFIDENTIAL reports',
        );
      }
    }

    // 2. Generate tracking code: DEN-YYYY-NNNN
    const trackingCode = this.generateTrackingCode();

    // 3. Auto-assign municipality by GPS if coordinates provided
    let municipalityId: string | undefined;
    if (input.latitude != null && input.longitude != null) {
      try {
        const jurisdiction = await this.jurisdictionsService.findByCoordinates(
          input.latitude,
          input.longitude,
        );
        municipalityId = jurisdiction?.organizationId;
      } catch {
        this.logger.warn('Could not resolve jurisdiction from GPS coordinates');
      }
    }

    // 4. Create the report
    const report = this.abuseReportRepository.create({
      trackingCode,
      municipalityId,
      status: AbuseReportStatus.FILED,
      abuseTypes: input.abuseTypes,
      description: input.description,
      locationProvince: input.locationProvince,
      locationCanton: input.locationCanton,
      locationDistrict: input.locationDistrict,
      locationAddress: input.locationAddress,
      latitude: input.latitude,
      longitude: input.longitude,
      evidenceUrls: input.evidenceUrls || [],
      privacyMode: input.privacyMode,
      priority: AbuseReportPriority.MEDIUM, // Default, classified later
    });

    const saved = await this.abuseReportRepository.save(report);

    // 5. Save identity data in separate table (Anexo D)
    if (input.privacyMode !== PrivacyMode.ANONYMOUS && input.fullName) {
      const identity = this.identityRepository.create({
        abuseReportId: saved.id,
        fullName: input.fullName,
        identificationNumber: input.identificationNumber!,
        phone: input.phone,
        email: input.email,
        consentGiven: input.consentGiven ?? false,
      });
      await this.identityRepository.save(identity);
    }

    // 6. Notify government admins
    this.notificationsService
      .sendToRole({
        role: UserRole.GOVERNMENT_ADMIN,
        type: NotificationType.ABUSE_REPORT_FILED,
        title: 'Nueva denuncia de maltrato',
        body: `Denuncia ${trackingCode} recibida - ${input.abuseTypes.join(', ')}`,
        referenceId: saved.id,
        referenceType: 'AbuseReport',
        jurisdictionId: municipalityId,
      })
      .catch((err) => this.logger.warn('Notification send failed', err));

    this.logger.log(`Abuse report ${trackingCode} filed successfully`);
    return saved;
  }

  // ─── Government admin mutations ────────────────────────────────

  async classifyReport(input: ClassifyReportInput): Promise<AbuseReport> {
    const report = await this.findOneById(input.id);

    if (report.status !== AbuseReportStatus.FILED) {
      throw new BadRequestException(
        `Report ${report.trackingCode} cannot be classified (current status: ${report.status})`,
      );
    }

    report.status = AbuseReportStatus.CLASSIFIED;
    report.classifiedAs = input.classifiedAs;
    report.priority = input.priority;

    const saved = await this.abuseReportRepository.save(report);
    this.logger.log(`Report ${report.trackingCode} classified as ${input.classifiedAs}`);
    return saved;
  }

  async assignInvestigator(id: string, assignedToId: string): Promise<AbuseReport> {
    const report = await this.findOneById(id);

    if (
      report.status !== AbuseReportStatus.CLASSIFIED &&
      report.status !== AbuseReportStatus.UNDER_INVESTIGATION
    ) {
      throw new BadRequestException(
        `Report ${report.trackingCode} cannot be assigned (current status: ${report.status})`,
      );
    }

    report.status = AbuseReportStatus.UNDER_INVESTIGATION;
    report.assignedToId = assignedToId;

    const saved = await this.abuseReportRepository.save(report);
    this.logger.log(`Report ${report.trackingCode} assigned to inspector ${assignedToId}`);
    return saved;
  }

  async resolveReport(input: ResolveReportInput): Promise<AbuseReport> {
    const report = await this.findOneById(input.id);

    if (report.status !== AbuseReportStatus.UNDER_INVESTIGATION) {
      throw new BadRequestException(
        `Report ${report.trackingCode} cannot be resolved (current status: ${report.status})`,
      );
    }

    report.status = AbuseReportStatus.RESOLVED;
    report.resolutionNotes = input.resolutionNotes;
    report.resolvedAt = new Date();

    const saved = await this.abuseReportRepository.save(report);
    this.logger.log(`Report ${report.trackingCode} resolved`);
    return saved;
  }

  // ─── Queries ───────────────────────────────────────────────────

  async trackReport(trackingCode: string): Promise<AbuseReport> {
    const report = await this.abuseReportRepository.findOne({
      where: { trackingCode: trackingCode.toUpperCase() },
    });

    if (!report) {
      throw new NotFoundException(`Report with tracking code ${trackingCode} not found`);
    }

    // Return status only — no identity data exposed
    return report;
  }

  async findPendingReports(municipalityId: string): Promise<AbuseReport[]> {
    return this.abuseReportRepository.find({
      where: {
        municipalityId,
        status: AbuseReportStatus.FILED,
      },
      relations: ['municipality'],
      order: { createdAt: 'DESC' },
    });
  }

  async findByStatus(
    municipalityId: string,
    status: AbuseReportStatus,
  ): Promise<AbuseReport[]> {
    return this.abuseReportRepository.find({
      where: { municipalityId, status },
      relations: ['municipality', 'assignedTo'],
      order: { createdAt: 'DESC' },
    });
  }

  async getReportMetrics(municipalityId: string): Promise<ReportMetrics> {
    const reports = await this.abuseReportRepository.find({
      where: { municipalityId },
    });

    const total = reports.length;
    const pendingClassification = reports.filter(
      (r) => r.status === AbuseReportStatus.FILED,
    ).length;
    const underInvestigation = reports.filter(
      (r) => r.status === AbuseReportStatus.UNDER_INVESTIGATION,
    ).length;
    const resolved = reports.filter(
      (r) =>
        r.status === AbuseReportStatus.RESOLVED ||
        r.status === AbuseReportStatus.CLOSED,
    ).length;

    // Calculate average response time (time from FILED to CLASSIFIED)
    const classifiedReports = reports.filter(
      (r) => r.status !== AbuseReportStatus.FILED && r.updatedAt && r.createdAt,
    );
    let avgResponseTimeHours = 0;
    if (classifiedReports.length > 0) {
      const totalHours = classifiedReports.reduce((sum, r) => {
        const diffMs = new Date(r.updatedAt).getTime() - new Date(r.createdAt).getTime();
        return sum + diffMs / (1000 * 60 * 60);
      }, 0);
      avgResponseTimeHours = Math.round((totalHours / classifiedReports.length) * 10) / 10;
    }

    const resolutionRate = total > 0 ? Math.round((resolved / total) * 100) / 100 : 0;

    // Scheduled visits = reports under investigation with assigned inspector
    const scheduledVisits = reports.filter(
      (r) =>
        r.status === AbuseReportStatus.UNDER_INVESTIGATION && r.assignedToId,
    ).length;

    return {
      totalReports: total,
      avgResponseTimeHours,
      resolutionRate,
      pendingClassification,
      underInvestigation,
      resolved,
      scheduledVisits,
    };
  }

  // ─── Private helpers ───────────────────────────────────────────

  private async findOneById(id: string): Promise<AbuseReport> {
    const report = await this.abuseReportRepository.findOne({
      where: { id },
      relations: ['municipality', 'assignedTo'],
    });
    if (!report) {
      throw new NotFoundException(`Report with ID ${id} not found`);
    }
    return report;
  }

  private generateTrackingCode(): string {
    const now = new Date();
    const year = now.getFullYear();
    const seq = String(++this.reportCodeCounter).padStart(4, '0');
    return `DEN-${year}-${seq}`;
  }
}
