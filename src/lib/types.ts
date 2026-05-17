export type SignupRole = 'helper' | 'derust' | 'learner';

export type RoleEntries = Record<SignupRole, PublicEntry[]>;

export interface PublicEntry {
  ign: string;
  createdAt: string;
  updatedAt: string;
}

export interface ContentItem {
  id: string;
  name: string;
  shortName: string | null;
  sortOrder: number;
  entries: RoleEntries;
}

export interface ContentCategoryGroup {
  id: string;
  name: string;
  sortOrder: number;
  contents: ContentItem[];
}

export interface ExpansionGroup {
  id: string;
  name: string;
  shortName: string;
  releaseOrder: number;
  categories: ContentCategoryGroup[];
}

export interface ContentResponse {
  expansions: ExpansionGroup[];
}

export interface SubmitEntryRequest {
  contentId: string;
  ign: string;
  role: SignupRole;
}

export const roleLabels: Record<SignupRole, string> = {
  helper: 'Helper',
  derust: 'Derust',
  learner: 'Learner'
};

export const roles: SignupRole[] = ['helper', 'derust', 'learner'];
