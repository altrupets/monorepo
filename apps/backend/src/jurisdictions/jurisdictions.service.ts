import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not } from 'typeorm';
import { Jurisdiction, JurisdictionLevel } from './entities/jurisdiction.entity';

@Injectable()
export class JurisdictionsService {
  constructor(
    @InjectRepository(Jurisdiction)
    private readonly jurisdictionRepository: Repository<Jurisdiction>,
  ) {}

  async findAll(): Promise<Jurisdiction[]> {
    return this.jurisdictionRepository.find({
      order: { level: 'ASC', name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Jurisdiction> {
    const jurisdiction = await this.jurisdictionRepository.findOne({
      where: { id },
      relations: ['parent'],
    });
    if (!jurisdiction) {
      throw new NotFoundException(`Jurisdiction with ID ${id} not found`);
    }
    return jurisdiction;
  }

  async findByLevel(level: JurisdictionLevel): Promise<Jurisdiction[]> {
    return this.jurisdictionRepository.find({
      where: { level },
      order: { name: 'ASC' },
    });
  }

  async findByParent(parentId: string): Promise<Jurisdiction[]> {
    return this.jurisdictionRepository.find({
      where: { parentId },
      order: { name: 'ASC' },
    });
  }

  async findProvinces(): Promise<Jurisdiction[]> {
    return this.findByLevel(JurisdictionLevel.PROVINCE);
  }

  async findCantons(provinceId: string): Promise<Jurisdiction[]> {
    const province = await this.findOne(provinceId);
    return this.findByParent(province.id);
  }

  async findDistricts(cantonId: string): Promise<Jurisdiction[]> {
    return this.findByParent(cantonId);
  }

  async findByCoordinates(lat: number, lng: number): Promise<Jurisdiction | null> {
    const result = await this.jurisdictionRepository.query(
      `SELECT * FROM jurisdictions
       WHERE ST_Contains(geometry, ST_SetSRID(ST_MakePoint($1, $2), 4326))
       LIMIT 1`,
      [lng, lat],
    );
    return result[0] || null;
  }

  async seedCostaRicaJurisdictions(): Promise<void> {
    const existing = await this.jurisdictionRepository.count();
    if (existing > 0) {
      return;
    }

    const provinces = [
      { name: 'Alajuela', code: 'AL' },
      { name: 'Cartago', code: 'CA' },
      { name: 'Guanacaste', code: 'GU' },
      { name: 'Heredia', code: 'HE' },
      { name: 'Limón', code: 'LI' },
      { name: 'Puntarenas', code: 'PU' },
      { name: 'San José', code: 'SJ' },
    ];

    for (const prov of provinces) {
      const province = this.jurisdictionRepository.create({
        name: prov.name,
        level: JurisdictionLevel.PROVINCE,
      });
      await this.jurisdictionRepository.save(province);
    }
  }
}
