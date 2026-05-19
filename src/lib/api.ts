import type {
  ContentCategoryGroup,
  ContentResponse,
  DeepDungeonRow,
  MountTable,
  SubmitEntriesRequest,
  SubmitEntryRequest
} from './types';

async function readJson<T>(response: Response): Promise<T> {
  const body = (await response.json().catch(() => null)) as T | { error?: string } | null;

  if (!response.ok) {
    const message =
      body && typeof body === 'object' && 'error' in body && body.error
        ? body.error
        : 'Request failed.';
    throw new Error(message);
  }

  return body as T;
}

export async function fetchContent(
  extremeExpansionId = 'dawntrail',
  savageExpansionId = 'dawntrail'
): Promise<ContentResponse> {
  const [ultimates, extremes, savages] = await Promise.all([
    fetchUltimates(),
    fetchExtremes(extremeExpansionId),
    fetchSavages(savageExpansionId)
  ]);

  return {
    extremeExpansionId,
    savageExpansionId,
    categories: [ultimates, extremes, savages]
  };
}

export async function fetchUltimates(): Promise<ContentCategoryGroup> {
  const response = await fetch('/api/content/ultimates');
  return readJson<ContentCategoryGroup>(response);
}

export async function fetchExtremes(expansionId = 'dawntrail'): Promise<ContentCategoryGroup> {
  const params = new URLSearchParams({ expansionId });
  const response = await fetch(`/api/content/extremes?${params.toString()}`);
  return readJson<ContentCategoryGroup>(response);
}

export async function fetchSavages(expansionId = 'dawntrail'): Promise<ContentCategoryGroup> {
  const params = new URLSearchParams({ expansionId });
  const response = await fetch(`/api/content/savages?${params.toString()}`);
  return readJson<ContentCategoryGroup>(response);
}

export async function submitEntry(payload: SubmitEntryRequest): Promise<void> {
  const response = await fetch('/api/entries', {
    method: 'PUT',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify(payload)
  });

  await readJson<{ ok: true }>(response);
}

export async function submitEntries(payload: SubmitEntriesRequest): Promise<void> {
  const response = await fetch('/api/entries/batch', {
    method: 'PUT',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify(payload)
  });

  await readJson<{ ok: true }>(response);
}

export async function fetchDeepDungeonProgress(): Promise<DeepDungeonRow[]> {
  const response = await fetch('/api/deep-dungeon-progress');
  return readJson<DeepDungeonRow[]>(response);
}

export async function saveDeepDungeonProgress(rows: DeepDungeonRow[]): Promise<void> {
  const response = await fetch('/api/deep-dungeon-progress', {
    method: 'PUT',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify({ rows })
  });

  await readJson<{ ok: true }>(response);
}

export async function fetchMountProgress(expansionId = 'dawntrail'): Promise<MountTable> {
  const params = new URLSearchParams({ expansionId });
  const response = await fetch(`/api/mount-progress?${params.toString()}`);
  return readJson<MountTable>(response);
}

export async function saveMountProgress(expansionId: string, rows: MountTable['rows']): Promise<void> {
  const response = await fetch('/api/mount-progress', {
    method: 'PUT',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify({ expansionId, rows })
  });

  await readJson<{ ok: true }>(response);
}
