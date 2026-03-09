import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WishlistItem, WishlistCategory, WishlistPriority } from './entities/wishlist-item.entity';

@Injectable()
export class WishlistService {
  constructor(
    @InjectRepository(WishlistItem)
    private readonly wishlistRepository: Repository<WishlistItem>,
  ) {}

  async findAll(): Promise<WishlistItem[]> {
    return this.wishlistRepository.find({
      order: [
        { priority: 'DESC' },
        { createdAt: 'DESC' },
      ],
    });
  }

  async findOne(id: string): Promise<WishlistItem> {
    const item = await this.wishlistRepository.findOne({
      where: { id },
    });
    if (!item) {
      throw new NotFoundException(`WishlistItem with ID ${id} not found`);
    }
    return item;
  }

  async findByCasaCuna(casaCunaId: string): Promise<WishlistItem[]> {
    return this.wishlistRepository.find({
      where: { casaCunaId, isPurchased: false },
      order: [
        { priority: 'DESC' },
        { createdAt: 'DESC' },
      ],
    });
  }

  async findByCategory(category: WishlistCategory): Promise<WishlistItem[]> {
    return this.wishlistRepository.find({
      where: { category, isPurchased: false },
      order: { priority: 'DESC' },
    });
  }

  async findUrgent(): Promise<WishlistItem[]> {
    return this.wishlistRepository.find({
      where: {
        priority: WishlistPriority.URGENT,
        isPurchased: false,
      },
      order: { createdAt: 'ASC' },
    });
  }

  async create(data: Partial<WishlistItem>): Promise<WishlistItem> {
    const item = this.wishlistRepository.create(data);
    return this.wishlistRepository.save(item);
  }

  async update(id: string, data: Partial<WishlistItem>): Promise<WishlistItem> {
    const item = await this.findOne(id);
    Object.assign(item, data);
    return this.wishlistRepository.save(item);
  }

  async markPurchased(id: string, purchasedBy: string): Promise<WishlistItem> {
    const item = await this.findOne(id);
    item.isPurchased = true;
    item.purchasedBy = purchasedBy;
    item.purchaseDate = new Date();
    return this.wishlistRepository.save(item);
  }

  async remove(id: string): Promise<void> {
    const item = await this.findOne(id);
    await this.wishlistRepository.remove(item);
  }
}
