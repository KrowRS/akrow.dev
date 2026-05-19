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

export interface ContentResponse {
  extremeExpansionId: string;
  savageExpansionId: string;
  categories: ContentCategoryGroup[];
}

export interface DeepDungeonRow {
  name: string;
  palace: boolean;
  heaven: string;
  eureka: string;
  pilgrims: string;
}

export interface MountTable {
  columns: string[];
  rows: MountProgressRow[];
}

export interface MountProgressRow {
  name: string;
  values: boolean[];
}

export interface SubmitEntryRequest {
  contentId: string;
  ign: string;
  role: SignupRole;
  expansionId?: string;
}

export interface SubmitEntriesRequest {
  ign: string;
  entries: Array<{
    contentId: string;
    role: SignupRole;
  }>;
}

export const roleLabels: Record<SignupRole, string> = {
  helper: 'Helper',
  derust: 'Derust',
  learner: 'Learner'
};

export const roles: SignupRole[] = ['helper', 'derust', 'learner'];
