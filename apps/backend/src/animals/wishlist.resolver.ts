import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { WishlistItem, WishlistCategory, WishlistPriority } from './entities/wishlist-item.entity';
import { WishlistService } from './wishlist.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Resolver(() => WishlistItem)
export class WishlistResolver {
  constructor(private readonly wishlistService: WishlistService) {}

  @Query(() => [WishlistItem], { name: 'wishlistItems' })
  async getWishlistItems(): Promise<WishlistItem[]> {
    return this.wishlistService.findAll();
  }

  @Query(() => [WishlistItem], { name: 'wishlistByCasaCuna' })
  async getWishlistByCasaCuna(
    @Args('casaCunaId', { type: () => ID }) casaCunaId: string,
  ): Promise<WishlistItem[]> {
    return this.wishlistService.findByCasaCuna(casaCunaId);
  }

  @Query(() => [WishlistItem], { name: 'urgentWishlistItems' })
  async getUrgentWishlistItems(): Promise<WishlistItem[]> {
    return this.wishlistService.findUrgent();
  }

  @Query(() => WishlistItem, { name: 'wishlistItem', nullable: true })
  async getWishlistItem(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<WishlistItem> {
    return this.wishlistService.findOne(id);
  }

  @Mutation(() => WishlistItem)
  @UseGuards(JwtAuthGuard)
  async createWishlistItem(
    @Args('name') name: string,
    @Args('category') category: WishlistCategory,
    @Args('casaCunaId', { type: () => ID }) casaCunaId: string,
    @Args('description', { nullable: true }) description?: string,
    @Args('priority', { nullable: true }) priority?: WishlistPriority,
    @Args('quantity', { nullable: true }) quantity?: number,
    @Args('unit', { nullable: true }) unit?: string,
    @Args('estimatedCost', { nullable: true }) estimatedCost?: number,
    @Args('requestedById', { nullable: true }) requestedById?: string,
  ): Promise<WishlistItem> {
    return this.wishlistService.create({
      name,
      category,
      casaCunaId,
      description,
      priority: priority || WishlistPriority.MEDIUM,
      quantity,
      unit,
      estimatedCost,
      requestedById,
    });
  }

  @Mutation(() => WishlistItem)
  @UseGuards(JwtAuthGuard)
  async updateWishlistItem(
    @Args('id', { type: () => ID }) id: string,
    @Args('name', { nullable: true }) name?: string,
    @Args('description', { nullable: true }) description?: string,
    @Args('quantity', { nullable: true }) quantity?: number,
    @Args('priority', { nullable: true }) priority?: WishlistPriority,
    @Args('isPurchased', { nullable: true }) isPurchased?: boolean,
  ): Promise<WishlistItem> {
    return this.wishlistService.update(id, {
      name,
      description,
      quantity,
      priority,
      isPurchased,
    });
  }

  @Mutation(() => WishlistItem)
  @UseGuards(JwtAuthGuard)
  async markWishlistItemPurchased(
    @Args('id', { type: () => ID }) id: string,
    @Args('purchasedBy') purchasedBy: string,
  ): Promise<WishlistItem> {
    return this.wishlistService.markPurchased(id, purchasedBy);
  }

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteWishlistItem(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<boolean> {
    await this.wishlistService.remove(id);
    return true;
  }
}
