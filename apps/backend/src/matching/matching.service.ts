import {
  Injectable,
  Logger,
  OnModuleInit,
  OnModuleDestroy,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as grpc from '@grpc/grpc-js';
import * as protoLoader from '@grpc/proto-loader';
import { join } from 'path';
import { RescuerCandidate } from './dto/rescuer-candidate.output';

interface GrpcRescuerCandidate {
  user_id: string;
  name: string;
  distance_km: number;
  available_capacity: number;
  score: number;
  explanation: string;
  score_breakdown: Record<string, number>;
}

interface GrpcFindRescuersResponse {
  candidates: GrpcRescuerCandidate[];
  total_evaluated: number;
  duration_ms: number;
  trace_id: string;
}

interface GrpcRecordOutcomeResponse {
  accepted: boolean;
}

interface MatchingGrpcClient extends grpc.Client {
  FindBestRescuers(
    request: Record<string, unknown>,
    options: { deadline: Date },
    callback: (error: grpc.ServiceError | null, response: GrpcFindRescuersResponse) => void,
  ): void;
  RecordRescueOutcome(
    request: Record<string, unknown>,
    options: { deadline: Date },
    callback: (error: grpc.ServiceError | null, response: GrpcRecordOutcomeResponse) => void,
  ): void;
}

@Injectable()
export class MatchingService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(MatchingService.name);
  private client: MatchingGrpcClient | null = null;
  private readonly grpcUrl: string;
  private readonly timeoutMs = 5000;

  constructor(private readonly configService: ConfigService) {
    this.grpcUrl = this.configService.get<string>(
      'AGENT_GRPC_URL',
      'localhost:50051',
    );
  }

  onModuleInit(): void {
    try {
      const protoPath = join(__dirname, 'proto', 'matching.proto');
      const packageDefinition = protoLoader.loadSync(protoPath, {
        keepCase: false,
        longs: String,
        enums: String,
        defaults: true,
        oneofs: true,
      });

      const protoDescriptor = grpc.loadPackageDefinition(packageDefinition);
      const matchingPackage = protoDescriptor.altrupets as Record<string, unknown>;
      const matching = matchingPackage.matching as Record<string, unknown>;
      const ServiceConstructor = matching.MatchingService as typeof grpc.Client;

      this.client = new ServiceConstructor(
        this.grpcUrl,
        grpc.credentials.createInsecure(),
      ) as MatchingGrpcClient;

      this.logger.log(`gRPC client initialized, target: ${this.grpcUrl}`);
    } catch (error) {
      this.logger.error(
        'Failed to initialize gRPC client',
        error instanceof Error ? error.message : String(error),
      );
    }
  }

  onModuleDestroy(): void {
    if (this.client) {
      this.client.close();
      this.logger.log('gRPC client closed');
    }
  }

  async findBestRescuers(
    rescueAlertId: string,
    latitude: number,
    longitude: number,
    urgency?: string,
    animalType?: string,
    maxCandidates?: number,
  ): Promise<{ candidates: RescuerCandidate[]; totalEvaluated: number; durationMs: number }> {
    if (!this.client) {
      this.logger.warn('gRPC client not available, returning empty results');
      return { candidates: [], totalEvaluated: 0, durationMs: 0 };
    }

    return new Promise((resolve) => {
      const deadline = new Date(Date.now() + this.timeoutMs);

      this.client!.FindBestRescuers(
        {
          rescue_alert_id: rescueAlertId,
          latitude,
          longitude,
          urgency: urgency ?? '',
          animal_type: animalType ?? '',
          max_candidates: maxCandidates ?? 5,
          trace_id: '',
        },
        { deadline },
        (error, response) => {
          if (error) {
            this.logger.error(
              `gRPC FindBestRescuers failed: ${error.message}`,
              error.stack,
            );
            resolve({ candidates: [], totalEvaluated: 0, durationMs: 0 });
            return;
          }

          const candidates: RescuerCandidate[] = (response.candidates ?? []).map(
            (c: GrpcRescuerCandidate) => ({
              userId: c.user_id,
              name: c.name,
              distanceKm: c.distance_km,
              availableCapacity: c.available_capacity,
              score: c.score,
              explanation: c.explanation,
              scoreBreakdown: c.score_breakdown ?? {},
            }),
          );

          resolve({
            candidates,
            totalEvaluated: response.total_evaluated,
            durationMs: response.duration_ms,
          });
        },
      );
    });
  }

  async recordRescueOutcome(
    rescueAlertId: string,
    rescuerId: string,
    animalId: string,
    successful: boolean,
    vetId?: string,
  ): Promise<boolean> {
    if (!this.client) {
      this.logger.warn('gRPC client not available, cannot record outcome');
      return false;
    }

    return new Promise((resolve) => {
      const deadline = new Date(Date.now() + this.timeoutMs);

      this.client!.RecordRescueOutcome(
        {
          rescue_alert_id: rescueAlertId,
          rescuer_id: rescuerId,
          animal_id: animalId,
          successful,
          vet_id: vetId ?? '',
          trace_id: '',
        },
        { deadline },
        (error, response) => {
          if (error) {
            this.logger.error(
              `gRPC RecordRescueOutcome failed: ${error.message}`,
              error.stack,
            );
            resolve(false);
            return;
          }

          resolve(response.accepted);
        },
      );
    });
  }
}
