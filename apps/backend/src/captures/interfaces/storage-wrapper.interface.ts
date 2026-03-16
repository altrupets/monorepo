import { CaptureRequest } from '../entities/capture-request.entity';

export interface CreateCaptureDto {
    latitude: number;
    longitude: number;
    description?: string;
    animalType: string;
}

export interface IStorageWrapper {
    saveCapture(data: CreateCaptureDto, image: Buffer, userId?: string): Promise<CaptureRequest>;
    getCaptures(): Promise<CaptureRequest[]>;
}

export const STORAGE_WRAPPER = 'STORAGE_WRAPPER';
