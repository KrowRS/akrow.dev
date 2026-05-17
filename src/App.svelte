<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchContent, submitEntry } from './lib/api';
  import { roleLabels, roles, type ContentResponse, type SignupRole } from './lib/types';

  let data: ContentResponse | null = null;
  let loading = true;
  let globalError = '';
  let selectedRoles: Record<string, SignupRole | undefined> = {};
  let names: Record<string, string> = {};
  let pendingContentId = '';
  let submitMessages: Record<string, string> = {};

  onMount(async () => {
    await loadContent();
  });

  async function loadContent() {
    loading = true;
    globalError = '';

    try {
      data = await fetchContent();
    } catch (error) {
      globalError = error instanceof Error ? error.message : 'Unable to load content.';
    } finally {
      loading = false;
    }
  }

  async function confirm(contentId: string) {
    const ign = names[contentId]?.trim() ?? '';
    const role = selectedRoles[contentId];

    submitMessages = { ...submitMessages, [contentId]: '' };

    if (!ign || !role) {
      submitMessages = { ...submitMessages, [contentId]: 'Enter your IGN and choose a role.' };
      return;
    }

    pendingContentId = contentId;

    try {
      await submitEntry({ contentId, ign, role, expansionId: data?.expansionId });
      data = await fetchContent(data?.expansionId ?? 'dawntrail');
      names = { ...names, [contentId]: '' };
      submitMessages = { ...submitMessages, [contentId]: 'Saved.' };
    } catch (error) {
      submitMessages = {
        ...submitMessages,
        [contentId]: error instanceof Error ? error.message : 'Unable to save entry.'
      };
    } finally {
      pendingContentId = '';
    }
  }
</script>

<svelte:head>
  <title>FFXIV Content Board</title>
</svelte:head>

<main class="page-shell">
  <header class="page-header">
    <div>
      <p class="eyebrow">Final Fantasy XIV</p>
      <h1>Content Board</h1>
    </div>
    <button class="refresh-button" type="button" on:click={loadContent} disabled={loading}>
      Refresh
    </button>
  </header>

  {#if loading}
    <section class="state-panel">Loading content...</section>
  {:else if globalError}
    <section class="state-panel error">
      <p>{globalError}</p>
      <button type="button" on:click={loadContent}>Try again</button>
    </section>
  {:else if data}
    <section class="expansion-section" aria-labelledby="content-heading">
      <div class="section-heading">
        <h2 id="content-heading">Available Content</h2>
        <span>{data.expansionId}</span>
      </div>

      {#each data.categories as category}
        <div class="category-block">
          <h3>{category.name}</h3>
          <div class="card-grid">
            {#each category.contents as content}
              <article class="content-card">
                <div class="card-title-row">
                  <div>
                    <h4>{content.name}</h4>
                    {#if content.shortName}
                      <p>{content.shortName}</p>
                    {/if}
                  </div>
                </div>

                <div class="role-control" aria-label={`Role for ${content.name}`}>
                  {#each roles as role}
                    <button
                      type="button"
                      class:active={selectedRoles[content.id] === role}
                      aria-pressed={selectedRoles[content.id] === role}
                      on:click={() => (selectedRoles = { ...selectedRoles, [content.id]: role })}
                    >
                      {roleLabels[role]}
                    </button>
                  {/each}
                </div>

                <div class="submit-row">
                  <input
                    aria-label={`In-game username for ${content.name}`}
                    placeholder="In-game username"
                    bind:value={names[content.id]}
                    maxlength="64"
                  />
                  <button
                    type="button"
                    on:click={() => confirm(content.id)}
                    disabled={pendingContentId === content.id}
                  >
                    {pendingContentId === content.id ? 'Saving' : 'Confirm'}
                  </button>
                </div>

                {#if submitMessages[content.id]}
                  <p class:error={submitMessages[content.id] !== 'Saved.'} class="submit-message">
                    {submitMessages[content.id]}
                  </p>
                {/if}

                <div class="entry-groups">
                  {#each roles as role}
                    <section>
                      <div class="entry-heading">
                        <strong>{roleLabels[role]}</strong>
                        <span>{content.entries[role].length}</span>
                      </div>
                      {#if content.entries[role].length}
                        <ul>
                          {#each content.entries[role] as entry}
                            <li>{entry.ign}</li>
                          {/each}
                        </ul>
                      {:else}
                        <p class="empty-list">No entries</p>
                      {/if}
                    </section>
                  {/each}
                </div>
              </article>
            {/each}
          </div>
        </div>
      {/each}
    </section>
  {/if}
</main>
