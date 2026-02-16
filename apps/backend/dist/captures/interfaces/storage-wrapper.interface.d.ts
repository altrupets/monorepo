import { CaptureRequest } from '../entities/capture-request.entity';
export interface CreateCaptureDto {
    latitude: number;
    longitude: number;
    description?: string;
    animalType: string;
}
export interface IStorageWrapper {
    saveCapture(data: CreateCaptureDto, image: Buffer): Promise<CaptureRequest>;
    getCaptures(): Promise<CaptureRequest[]>;
}
export declare const STORAGE_WRAPPER = "STORAGE_WRAPPER";
