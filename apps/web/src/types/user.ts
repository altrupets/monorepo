export interface User {
  id: string;
  username: string;
  roles: string[];
  firstName?: string;
  lastName?: string;
  phone?: string;
  identification?: string;
  country?: string;
  province?: string;
  canton?: string;
  district?: string;
  createdAt: string;
  updatedAt: string;
}

export interface GraphQLResponse<T> {
  data?: T;
  errors?: Array<{ message: string }>;
}
