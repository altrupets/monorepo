import { ObjectType, Field, Float } from '@nestjs/graphql';

@ObjectType()
export class Point {
  @Field(() => String)
  type: string = 'Point';

  @Field(() => [Float])
  coordinates: number[];
}

@ObjectType()
export class MultiPolygon {
  @Field(() => String)
  type: string = 'MultiPolygon';

  @Field(() => [[[ [Float] ]]])
  coordinates: number[][][][];
}
