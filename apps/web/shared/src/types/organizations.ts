import type { OrganizationType, OrganizationStatus, OrganizationRole } from './enums'

export interface Organization {
  id: string
  name: string
  type: OrganizationType
  legalId?: string
  description?: string
  email?: string
  phone?: string
  website?: string
  address?: string
  country?: string
  province?: string
  canton?: string
  district?: string
  status: OrganizationStatus
  legalDocumentationBase64?: string | null
  financialStatementsBase64?: string | null
  legalRepresentativeId?: string
  memberCount: number
  maxCapacity: number
  isActive: boolean
  isVerified: boolean
  createdAt: Date
  updatedAt: Date
}

export interface RegisterOrganizationInput {
  name: string
  type: OrganizationType
  legalId?: string
  description?: string
  email?: string
  phone?: string
  website?: string
  address?: string
  country?: string
  province?: string
  canton?: string
  district?: string
  legalDocumentationBase64?: string
  financialStatementsBase64?: string
  maxCapacity?: number
}

export interface SearchOrganizationsInput {
  name?: string
  type?: OrganizationType
  status?: OrganizationStatus
  country?: string
  province?: string
  canton?: string
}

export interface RequestMembershipInput {
  organizationId: string
  requestMessage?: string
}

export interface ApproveMembershipInput {
  membershipId: string
  role?: OrganizationRole
}

export interface RejectMembershipInput {
  membershipId: string
  rejectionReason?: string
}

export interface AssignRoleInput {
  membershipId: string
  role: OrganizationRole
}

export interface OrganizationMembership {
  id: string
  organizationId: string
  organization?: Organization
  userId: string
  status: import('./enums').MembershipStatus
  role: OrganizationRole
  requestMessage?: string
  rejectionReason?: string
  approvedBy?: string
  approvedAt?: Date
  createdAt: Date
  updatedAt: Date
}
