import { Repository } from 'typeorm';
import { IStorageWrapper, CreateCaptureDto } from '../interfaces/storage-wrapper.interface';
import { CaptureRequest } from '../entities/capture-request.entity';
export declare class LocalStorageService implements IStorageWrapper {
    private readonly repository;
    private readonly uploadPath;
    constructor(repository: Repository<CaptureRequest>);
    private ensureUploadPath;
    saveCapture(data: CreateCaptureDto, image: Buffer): Promise<CaptureRequest>;
    getCaptures(): Promise<CaptureRequest[]>;
}
