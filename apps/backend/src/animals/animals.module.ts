import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AnimalsService } from './animals.service';
import { AnimalsResolver } from './animals.resolver';
import { Animal } from './entities/animal.entity';
import { CasaCuna } from './entities/casa-cuna.entity';
import { WishlistItem } from './entities/wishlist-item.entity';
import { CasasCunasService } from './casas-cunas.service';
import { CasasCunasResolver } from './casas-cunas.resolver';
import { WishlistService } from './wishlist.service';
import { WishlistResolver } from './wishlist.resolver';

@Module({
  imports: [TypeOrmModule.forFeature([Animal, CasaCuna, WishlistItem])],
  providers: [
    AnimalsService,
    AnimalsResolver,
    CasasCunasService,
    CasasCunasResolver,
    WishlistService,
    WishlistResolver,
  ],
  exports: [AnimalsService, CasasCunasService, WishlistService],
})
export class AnimalsModule {}
