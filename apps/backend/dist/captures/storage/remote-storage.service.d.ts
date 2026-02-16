import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { IStorageWrapper, CreateCaptureDto } from '../interfaces/storage-wrapper.interface';
import { CaptureRequest } from '../entities/capture-request.entity';
export declare class RemoteStorageService implements IStorageWrapper {
    private readonly repository;
    private readonly configService;
    private readonly logger;
    constructor(repository: Repository<CaptureRequest>, configService: ConfigService);
    saveCapture(data: CreateCaptureDto, image: Buffer): Promise<CaptureRequest>;
    getCaptures(): Promise<CaptureRequest[]>;
}
