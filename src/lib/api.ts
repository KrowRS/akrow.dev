import type { ContentCategoryGroup, ContentResponse, SubmitEntryRequest } from './types';

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

export async function fetchContent(expansionId = 'dawntrail'): Promise<ContentResponse> {
  const [ultimates, extremes, savages] = await Promise.all([
    fetchUltimates(),
    fetchExtremes(expansionId),
    fetchSavages(expansionId)
  ]);

  return {
    expansionId,
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
