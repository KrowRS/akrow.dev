import type { ContentResponse, SubmitEntryRequest } from './types';

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

export async function fetchContent(): Promise<ContentResponse> {
  const response = await fetch('/api/content');
  return readJson<ContentResponse>(response);
}

export async function submitEntry(payload: SubmitEntryRequest): Promise<ContentResponse> {
  const response = await fetch('/api/entries', {
    method: 'PUT',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify(payload)
  });

  return readJson<ContentResponse>(response);
}
