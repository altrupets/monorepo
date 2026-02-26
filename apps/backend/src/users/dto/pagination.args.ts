import { Field, Int, InputType, ObjectType, registerEnumType } from '@nestjs/graphql';

export enum SortOrder {
  ASC = 'ASC',
  DESC = 'DESC',
}

registerEnumType(SortOrder, {
  name: 'SortOrder',
  description: 'Sort order for pagination',
});

@ObjectType()
export class PaginatedUsers {
  @Field(() => [String])
  items: string[];

  @Field(() => Int)
  total: number;

  @Field(() => Int)
  page: number;

  @Field(() => Int)
  limit: number;

  @Field(() => Int)
  totalPages: number;

  @Field(() => Boolean)
  hasNext: boolean;

  @Field(() => Boolean)
  hasPrevious: boolean;
}

@InputType()
export class PaginationArgs {
  @Field(() => Int, { defaultValue: 1 })
  page: number = 1;

  @Field(() => Int, { defaultValue: 10 })
  limit: number = 10;

  @Field(() => String, { nullable: true })
  sortBy?: string;

  @Field(() => SortOrder, { defaultValue: SortOrder.DESC })
  order: SortOrder = SortOrder.DESC;
}
