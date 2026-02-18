export enum CaptureStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
}

export interface Capture {
  id: string
  latitude: number
  longitude: number
  description?: string
  animalType: string
  imageUrl?: string
  status: CaptureStatus
  createdAt: Date
  updatedAt: Date
}

export interface CreateCaptureInput {
  latitude: number
  longitude: number
  description?: string
  animalType: string
  imageBase64: string
}
