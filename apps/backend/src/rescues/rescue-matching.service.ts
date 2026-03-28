import { Injectable, Logger } from '@nestjs/common';
import { EntityManager } from 'typeorm';
import { UserRole } from '../auth/roles/user-role.enum';
import { RescueStatus } from './enums/rescue-status.enum';

interface NearbyUser {
  userId: string;
  distance: number;
  username: string;
  firstName?: string;
  lastName?: string;
  phone?: string;
}

@Injectable()
export class RescueMatchingService {
  private readonly logger = new Logger(RescueMatchingService.name);

  constructor(private readonly entityManager: EntityManager) {}

  /**
   * Find nearby users with HELPER role using the Haversine formula.
   * Users have latitude/longitude as decimal columns, not PostGIS geometry.
   * Excludes users already assigned to an active rescue (ACCEPTED or IN_PROGRESS).
   */
  async findNearbyAuxiliares(
    lon: number,
    lat: number,
    radiusMeters: number,
  ): Promise<NearbyUser[]> {
    return this.findNearbyUsersByRole(lon, lat, radiusMeters, UserRole.HELPER);
  }

  /**
   * Find nearby users with RESCUER role using the Haversine formula.
   * Excludes users already assigned to an active rescue (ACCEPTED or IN_PROGRESS).
   */
  async findAvailableRescuers(
    lon: number,
    lat: number,
    radiusMeters: number,
  ): Promise<NearbyUser[]> {
    return this.findNearbyUsersByRole(lon, lat, radiusMeters, UserRole.RESCUER);
  }

  /**
   * Update a user's current latitude/longitude.
   */
  async updateUserLocation(
    userId: string,
    lat: number,
    lng: number,
  ): Promise<void> {
    await this.entityManager.query(
      `UPDATE users SET latitude = $1, longitude = $2, "updatedAt" = NOW() WHERE id = $3`,
      [lat, lng, userId],
    );
  }

  private async findNearbyUsersByRole(
    lon: number,
    lat: number,
    radiusMeters: number,
    role: UserRole,
  ): Promise<NearbyUser[]> {
    // Haversine formula to compute distance in meters between two lat/lng pairs.
    // Excludes users who are currently assigned to an ACCEPTED or IN_PROGRESS rescue.
    const query = `
      SELECT
        u.id AS "userId",
        u.username,
        u."firstName",
        u."lastName",
        u.phone,
        (
          6371000 * acos(
            LEAST(1.0, cos(radians($1)) * cos(radians(u.latitude))
              * cos(radians(u.longitude) - radians($2))
              + sin(radians($1)) * sin(radians(u.latitude)))
          )
        ) AS distance
      FROM users u
      WHERE $3 = ANY(u.roles)
        AND u."isActive" = true
        AND u.latitude IS NOT NULL
        AND u.longitude IS NOT NULL
        AND u.id NOT IN (
          SELECT COALESCE(ra."auxiliarId", ra."rescuerId")
          FROM rescue_alerts ra
          WHERE ra.status IN ($4, $5)
            AND (ra."auxiliarId" IS NOT NULL OR ra."rescuerId" IS NOT NULL)
        )
      HAVING (
        6371000 * acos(
          LEAST(1.0, cos(radians($1)) * cos(radians(u.latitude))
            * cos(radians(u.longitude) - radians($2))
            + sin(radians($1)) * sin(radians(u.latitude)))
        )
      ) <= $6
      ORDER BY distance ASC
    `;

    try {
      const results = await this.entityManager.query(query, [
        lat,
        lon,
        role,
        RescueStatus.ACCEPTED,
        RescueStatus.IN_PROGRESS,
        radiusMeters,
      ]);

      return results.map((row: any) => ({
        userId: row.userId,
        distance: parseFloat(row.distance),
        username: row.username,
        firstName: row.firstName ?? undefined,
        lastName: row.lastName ?? undefined,
        phone: row.phone ?? undefined,
      }));
    } catch (error) {
      this.logger.error(
        'Error finding nearby users',
        error instanceof Error ? error.message : String(error),
      );
      return [];
    }
  }
}
