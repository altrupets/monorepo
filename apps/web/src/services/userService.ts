import { graphqlRequest } from './graphql';
import { User } from '../types/user';

const USERS_QUERY = `
  query GetUsers {
    users {
      id
      username
      roles
      firstName
      lastName
      phone
      identification
      country
      province
      canton
      district
      createdAt
      updatedAt
    }
  }
`;

const USER_QUERY = `
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      username
      roles
      firstName
      lastName
      phone
      identification
      country
      province
      canton
      district
      createdAt
      updatedAt
    }
  }
`;

export async function getUsers(): Promise<User[]> {
  const data = await graphqlRequest<{ users: User[] }>(USERS_QUERY);
  return data.users;
}

export async function getUser(id: string): Promise<User> {
  const data = await graphqlRequest<{ user: User }>(USER_QUERY, { id });
  return data.user;
}
